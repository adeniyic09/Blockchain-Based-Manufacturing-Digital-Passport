;; lifecycle-tracking.clar
;; This contract follows product through use and disposal

(define-data-var last-event-id uint u0)

(define-map lifecycle-events
  { event-id: uint }
  {
    product-id: uint,
    event-type: (string-utf8 50),
    event-date: uint,
    recorded-by: principal,
    location: (string-utf8 100),
    description: (string-utf8 500)
  }
)

(define-map product-status
  { product-id: uint }
  {
    current-owner: principal,
    status: (string-utf8 50),
    last-updated: uint
  }
)

(define-public (record-lifecycle-event
    (product-id uint)
    (event-type (string-utf8 50))
    (location (string-utf8 100))
    (description (string-utf8 500)))
  (let
    (
      (new-id (+ (var-get last-event-id) u1))
    )
    (var-set last-event-id new-id)
    (ok (map-set lifecycle-events
      { event-id: new-id }
      {
        product-id: product-id,
        event-type: event-type,
        event-date: block-height,
        recorded-by: tx-sender,
        location: location,
        description: description
      }
    ))
  )
)

(define-public (update-product-status
    (product-id uint)
    (status (string-utf8 50)))
  (ok (map-set product-status
    { product-id: product-id }
    {
      current-owner: tx-sender,
      status: status,
      last-updated: block-height
    }
  ))
)

(define-public (transfer-ownership (product-id uint) (new-owner principal))
  (let
    (
      (status (unwrap! (map-get? product-status { product-id: product-id }) (err u1)))
    )
    (asserts! (is-eq tx-sender (get current-owner status)) (err u2))
    (ok (map-set product-status
      { product-id: product-id }
      (merge status {
        current-owner: new-owner,
        last-updated: block-height
      })
    ))
  )
)

(define-read-only (get-lifecycle-event (event-id uint))
  (map-get? lifecycle-events { event-id: event-id })
)

(define-read-only (get-product-status (product-id uint))
  (map-get? product-status { product-id: product-id })
)
