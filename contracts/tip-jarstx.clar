;; TipJarSTX - Simple STX tipping contract for creators

;; Error codes
(define-constant ERR-INVALID-AMOUNT (err u100))
(define-constant ERR-NOT-OWNER (err u101))
(define-constant ERR-INSUFFICIENT-BALANCE (err u102))
(define-constant ERR-TRANSFER-FAILED (err u103))
(define-constant ERR-ZERO-BALANCE (err u104))

;; Contract owner (creator who receives tips)
(define-constant contract-owner tx-sender)

;; Data structures
(define-map tips 
  { donor: principal } 
  { amount: uint, tip-count: uint, last-tip: uint })

(define-data-var total-tips uint u0)
(define-data-var total-donors uint u0)

;; ========== TIP FUNCTIONS ==========

(define-public (send-tip (amount uint))
  (let (
    (donor tx-sender)
    (current-tip (default-to { amount: u0, tip-count: u0, last-tip: u0 } 
                             (map-get? tips { donor: donor })))
  )
    (begin
      ;; Validate tip amount
      (asserts! (> amount u0) ERR-INVALID-AMOUNT)
      
      ;; Transfer STX from donor to contract
      (try! (stx-transfer? amount donor (as-contract tx-sender)))
      
      ;; Update donor's tip record
      (let (
        (new-amount (+ (get amount current-tip) amount))
        (new-count (+ (get tip-count current-tip) u1))
        (is-new-donor (is-eq (get amount current-tip) u0))
      )
        (begin
          ;; Update tip mapping
          (map-set tips { donor: donor } 
            { 
              amount: new-amount, 
              tip-count: new-count, 
              last-tip: stacks-block-height 
            })
          
          ;; Update total tips
          (var-set total-tips (+ (var-get total-tips) amount))
          
          ;; Update donor count if this is a new donor
          (if is-new-donor
            (var-set total-donors (+ (var-get total-donors) u1))
            true)
          
          ;; Print event for logging
          (print { 
            action: "tip-sent", 
            donor: donor, 
            amount: amount, 
            total-from-donor: new-amount,
            block: stacks-block-height
          })
          
          (ok new-amount)
        )
      )
    )
  )
)

(define-public (send-tip-with-message (amount uint) (message (string-ascii 280)))
  (let (
    (tip-result (try! (send-tip amount)))
  )
    (begin
      (print { 
        action: "tip-with-message", 
        donor: tx-sender, 
        amount: amount, 
        message: message 
      })
      (ok tip-result)
    )
  )
)

;; ========== WITHDRAW FUNCTIONS ==========

(define-public (withdraw-tips (amount uint))
  (begin
    ;; Only contract owner can withdraw
    (asserts! (is-eq tx-sender contract-owner) ERR-NOT-OWNER)
    
    ;; Check if amount is valid
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)
    
    ;; Check if contract has sufficient balance
    (asserts! (<= amount (stx-get-balance (as-contract tx-sender))) ERR-INSUFFICIENT-BALANCE)
    
    ;; Transfer STX from contract to owner
    (try! (as-contract (stx-transfer? amount tx-sender contract-owner)))
    
    ;; Update total tips (for tracking purposes)
    (var-set total-tips (- (var-get total-tips) amount))
    
    ;; Print event
    (print { 
      action: "withdrawal", 
      owner: contract-owner, 
      amount: amount, 
      block: stacks-block-height 
    })
    
    (ok amount)
  )
)

(define-public (withdraw-all)
  (let (
    (balance (stx-get-balance (as-contract tx-sender)))
  )
    (begin
      (asserts! (is-eq tx-sender contract-owner) ERR-NOT-OWNER)
      (asserts! (> balance u0) ERR-ZERO-BALANCE)
      (try! (withdraw-tips balance))
      (ok balance)
    )
  )
)

;; ========== READ-ONLY FUNCTIONS ==========

(define-read-only (get-contract-balance)
  (ok (stx-get-balance (as-contract tx-sender)))
)

(define-read-only (get-total-tips)
  (ok (var-get total-tips))
)

(define-read-only (get-total-donors)
  (ok (var-get total-donors))
)

(define-read-only (get-donor-info (donor principal))
  (ok (default-to 
    { amount: u0, tip-count: u0, last-tip: u0 } 
    (map-get? tips { donor: donor })
  ))
)

(define-read-only (get-donor-total (donor principal))
  (ok (get amount (default-to 
    { amount: u0, tip-count: u0, last-tip: u0 } 
    (map-get? tips { donor: donor })
  )))
)

(define-read-only (get-contract-owner)
  (ok contract-owner)
)

(define-read-only (get-contract-info)
  (ok {
    name: "TipJarSTX",
    version: "1.0.0",
    owner: contract-owner,
    total-tips: (var-get total-tips),
    total-donors: (var-get total-donors),
    contract-balance: (stx-get-balance (as-contract tx-sender))
  })
)

;; ========== UTILITY FUNCTIONS ==========

(define-read-only (is-donor (user principal))
  (ok (> (get amount (default-to 
    { amount: u0, tip-count: u0, last-tip: u0 } 
    (map-get? tips { donor: user })
  )) u0))
)

(define-read-only (get-tip-stats)
  (ok {
    total-tips: (var-get total-tips),
    total-donors: (var-get total-donors),
    contract-balance: (stx-get-balance (as-contract tx-sender)),
    average-tip: (if (> (var-get total-donors) u0)
                   (/ (var-get total-tips) (var-get total-donors))
                   u0)
  })
)
