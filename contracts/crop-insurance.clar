;; Crop Insurance Pool Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-insufficient-balance (err u101))
(define-constant err-invalid-amount (err u102))
(define-constant err-not-insured (err u103))
(define-constant err-already-claimed (err u104))

;; Data vars
(define-data-var pool-balance uint u0)
(define-data-var min-premium uint u100)
(define-data-var payout-multiplier uint u3)

;; Data maps
(define-map insurances
    principal
    {
        premium: uint,
        coverage: uint,
        start-block: uint,
        claimed: bool
    }
)

;; Public functions
(define-public (join-pool (premium uint))
    (let (
        (coverage (* premium (var-get payout-multiplier)))
    )
        (asserts! (>= premium (var-get min-premium)) err-invalid-amount)
        (try! (stx-transfer? premium tx-sender (as-contract tx-sender)))
        (var-set pool-balance (+ (var-get pool-balance) premium))
        (ok (map-set insurances tx-sender {
            premium: premium,
            coverage: coverage,
            start-block: block-height,
            claimed: false
        }))
    )
)

(define-public (claim-insurance)
    (let (
        (insurance (unwrap! (map-get? insurances tx-sender) err-not-insured))
        (is-claimed (get claimed insurance))
        (coverage (get coverage insurance))
    )
        (asserts! (not is-claimed) err-already-claimed)
        (asserts! (>= (var-get pool-balance) coverage) err-insufficient-balance)
        (try! (as-contract (stx-transfer? coverage (as-contract tx-sender) tx-sender)))
        (var-set pool-balance (- (var-get pool-balance) coverage))
        (map-set insurances tx-sender (merge insurance { claimed: true }))
        (ok coverage)
    )
)

;; Admin functions
(define-public (set-premium-minimum (amount uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (var-set min-premium amount)
        (ok true)
    )
)

(define-public (set-payout-multiplier (multiplier uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (var-set payout-multiplier multiplier)
        (ok true)
    )
)

;; Read only functions
(define-read-only (get-pool-balance)
    (ok (var-get pool-balance))
)

(define-read-only (get-insurance-info (farmer principal))
    (ok (map-get? insurances farmer))
)
