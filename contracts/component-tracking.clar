;; component-tracking.clar
;; This contract records parts and materials

(define-data-var last-component-id uint u0)

(define-map components
  { component-id: uint }
  {
    name: (string-utf8 100),
    supplier: principal,
    batch-number: (string-utf8 50),
    material-type: (string-utf8 50),
    production-date: uint
  }
)

(define-map product-components
  { product-id: uint, component-id: uint }
  { quantity: uint }
)

(define-public (register-component
    (name (string-utf8 100))
    (batch-number (string-utf8 50))
    (material-type (string-utf8 50)))
  (let
    (
      (new-id (+ (var-get last-component-id) u1))
    )
    (var-set last-component-id new-id)
    (ok (map-set components
      { component-id: new-id }
      {
        name: name,
        supplier: tx-sender,
        batch-number: batch-number,
        material-type: material-type,
        production-date: block-height
      }
    ))
  )
)

(define-public (add-component-to-product (product-id uint) (component-id uint) (quantity uint))
  (ok (map-set product-components
    { product-id: product-id, component-id: component-id }
    { quantity: quantity }
  ))
)

(define-read-only (get-component (component-id uint))
  (map-get? components { component-id: component-id })
)

(define-read-only (get-product-component (product-id uint) (component-id uint))
  (map-get? product-components { product-id: product-id, component-id: component-id })
)
