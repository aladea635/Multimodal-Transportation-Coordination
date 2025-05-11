;; Carrier Verification Contract
;; Validates transportation providers in the network

(define-data-var admin principal tx-sender)

;; Map to store verified carriers
(define-map verified-carriers principal
  {
    name: (string-utf8 100),
    carrier-type: (string-utf8 20),
    verification-date: uint,
    is-active: bool
  }
)

;; Public function to verify a new carrier (admin only)
(define-public (verify-carrier
    (carrier principal)
    (name (string-utf8 100))
    (carrier-type (string-utf8 20)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u100))
    (asserts! (is-none (map-get? verified-carriers carrier)) (err u101))
    (ok (map-set verified-carriers carrier
      {
        name: name,
        carrier-type: carrier-type,
        verification-date: block-height,
        is-active: true
      }
    ))
  )
)

;; Public function to deactivate a carrier (admin only)
(define-public (deactivate-carrier (carrier principal))
  (let ((carrier-data (unwrap! (map-get? verified-carriers carrier) (err u102))))
    (asserts! (is-eq tx-sender (var-get admin)) (err u100))
    (ok (map-set verified-carriers carrier
      (merge carrier-data { is-active: false })
    ))
  )
)

;; Read-only function to check if a carrier is verified and active
(define-read-only (is-verified-carrier (carrier principal))
  (match (map-get? verified-carriers carrier)
    carrier-data (and (get is-active carrier-data) true)
    false
  )
)

;; Read-only function to get carrier details
(define-read-only (get-carrier-details (carrier principal))
  (map-get? verified-carriers carrier)
)

;; Function to transfer admin rights (admin only)
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u100))
    (ok (var-set admin new-admin))
  )
)
