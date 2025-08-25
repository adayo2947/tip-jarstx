# TipJarSTX Smart Contract

A decentralized tipping solution built on the Stacks blockchain that enables creators to receive STX tips from their community.

## Features

- 💸 **Direct Tipping**: Send STX tips directly to creators
- 💬 **Message Support**: Include optional messages with tips
- 📊 **Donor Tracking**: Comprehensive tracking of donor statistics
- 🔒 **Secure Withdrawals**: Only contract owner can withdraw accumulated tips
- 📈 **Transparent Stats**: Public access to contract statistics and donor information

## Contract Information

- **Name**: TipJarSTX
- **Version**: 1.0.0
- **Network**: Stacks Mainnet
- **Language**: Clarity

## Functions

### Public Functions

```clarity
(send-tip (amount uint))
(send-tip-with-message (amount uint) (message (string-ascii 280)))
(withdraw-tips (amount uint))
(withdraw-all)
```

### Read-Only Functions

```clarity
(get-contract-balance)
(get-total-tips)
(get-total-donors)
(get-donor-info (donor principal))
(get-donor-total (donor principal))
(get-contract-owner)
(get-contract-info)
(is-donor (user principal))
(get-tip-stats)
```

## Error Codes

| Code | Description |
|------|-------------|
| `u100` | Invalid amount |
| `u101` | Not contract owner |
| `u102` | Insufficient balance |
| `u103` | Transfer failed |
| `u104` | Zero balance |

## Usage

### Sending a Tip

```clarity
;; Send 100 STX tip
(contract-call? .tip-jarstx send-tip u100)

;; Send tip with message
(contract-call? .tip-jarstx send-tip-with-message u100 "Great work!")
```

### Withdrawing Tips (Contract Owner Only)

```clarity
;; Withdraw specific amount
(contract-call? .tip-jarstx withdraw-tips u1000)

;; Withdraw all tips
(contract-call? .tip-jarstx withdraw-all)
```


### Local Testing

1. Clone the repository
2. Install dependencies
3. Run Clarinet console:
```bash
clarinet console
```

## Security

- Contract owner is set at deployment
- Only contract owner can withdraw tips
- All transactions are validated and tracked
- Balance checks prevent unauthorized withdrawals

---

Built with ❤️ on Stacks
