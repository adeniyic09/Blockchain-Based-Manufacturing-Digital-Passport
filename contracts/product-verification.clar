;; product-verification.clar
;; This contract validates manufactured items

(define-data-var last-product-id uint u0)

(define-map products
  { product-id: uint }
  {
    manufacturer: principal,
    product-name: (string-utf8 100),
    serial-number: (string-utf8 50),
    manufacture-date: uint,
    verified: bool
  }
)

(define-public (register-product (product-name (string-utf8 100)) (serial-number (string-utf8 50)))
  (let
    (
      (new-id (+ (var-get last-product-id) u1))
    )
    (var-set last-product-id new-id)
    (ok (map-set products
      { product-id: new-id }
      {
        manufacturer: tx-sender,
        product-name: product-name,
        serial-number: serial-number,
        manufacture-date: block-height,
        verified: false
      }
    ))
  )
)

(define-public (verify-product (product-id uint))
  (let
    (
      (product (unwrap! (map-get? products { product-id: product-id }) (err u1)))
    )
    (asserts! (is-eq tx-sender (get manufacturer product)) (err u2))
    (ok (map-set products
      { product-id: product-id }
      (merge product { verified: true })
    ))
  )
)

(define-read-only (get-product (product-id uint))
  (map-get? products { product-id: product-id })
)
