;; assembly-verification.clar
;; This contract documents the production process

(define-data-var last-assembly-id uint u0)

(define-map assembly-records
  { assembly-id: uint }
  {
    product-id: uint,
    assembler: principal,
    assembly-date: uint,
    assembly-location: (string-utf8 100),
    assembly-notes: (string-utf8 500),
    verified: bool
  }
)

(define-map assembly-steps
  { assembly-id: uint, step-number: uint }
  {
    description: (string-utf8 200),
    completed: bool,
    completed-by: principal,
    completion-date: uint
  }
)

(define-public (create-assembly-record
    (product-id uint)
    (assembly-location (string-utf8 100))
    (assembly-notes (string-utf8 500)))
  (let
    (
      (new-id (+ (var-get last-assembly-id) u1))
    )
    (var-set last-assembly-id new-id)
    (ok (map-set assembly-records
      { assembly-id: new-id }
      {
        product-id: product-id,
        assembler: tx-sender,
        assembly-date: block-height,
        assembly-location: assembly-location,
        assembly-notes: assembly-notes,
        verified: false
      }
    ))
  )
)

(define-public (add-assembly-step
    (assembly-id uint)
    (step-number uint)
    (description (string-utf8 200)))
  (ok (map-set assembly-steps
    { assembly-id: assembly-id, step-number: step-number }
    {
      description: description,
      completed: false,
      completed-by: tx-sender,
      completion-date: u0
    }
  ))
)

(define-public (complete-assembly-step (assembly-id uint) (step-number uint))
  (let
    (
      (step (unwrap! (map-get? assembly-steps { assembly-id: assembly-id, step-number: step-number }) (err u1)))
    )
    (ok (map-set assembly-steps
      { assembly-id: assembly-id, step-number: step-number }
      (merge step {
        completed: true,
        completed-by: tx-sender,
        completion-date: block-height
      })
    ))
  )
)

(define-public (verify-assembly (assembly-id uint))
  (let
    (
      (assembly (unwrap! (map-get? assembly-records { assembly-id: assembly-id }) (err u1)))
    )
    (ok (map-set assembly-records
      { assembly-id: assembly-id }
      (merge assembly { verified: true })
    ))
  )
)

(define-read-only (get-assembly-record (assembly-id uint))
  (map-get? assembly-records { assembly-id: assembly-id })
)

(define-read-only (get-assembly-step (assembly-id uint) (step-number uint))
  (map-get? assembly-steps { assembly-id: assembly-id, step-number: step-number })
)
