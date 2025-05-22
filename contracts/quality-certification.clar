;; quality-certification.clar
;; This contract records testing results

(define-data-var last-certification-id uint u0)

(define-map quality-certifications
  { certification-id: uint }
  {
    product-id: uint,
    certifier: principal,
    certification-date: uint,
    certification-standard: (string-utf8 100),
    passed: bool,
    notes: (string-utf8 500)
  }
)

(define-map test-results
  { certification-id: uint, test-name: (string-utf8 100) }
  {
    result: (string-utf8 100),
    passed: bool,
    test-date: uint,
    tester: principal
  }
)

(define-public (create-certification
    (product-id uint)
    (certification-standard (string-utf8 100))
    (notes (string-utf8 500)))
  (let
    (
      (new-id (+ (var-get last-certification-id) u1))
    )
    (var-set last-certification-id new-id)
    (ok (map-set quality-certifications
      { certification-id: new-id }
      {
        product-id: product-id,
        certifier: tx-sender,
        certification-date: block-height,
        certification-standard: certification-standard,
        passed: false,
        notes: notes
      }
    ))
  )
)

(define-public (add-test-result
    (certification-id uint)
    (test-name (string-utf8 100))
    (result (string-utf8 100))
    (passed bool))
  (ok (map-set test-results
    { certification-id: certification-id, test-name: test-name }
    {
      result: result,
      passed: passed,
      test-date: block-height,
      tester: tx-sender
    }
  ))
)

(define-public (finalize-certification (certification-id uint) (passed bool))
  (let
    (
      (certification (unwrap! (map-get? quality-certifications { certification-id: certification-id }) (err u1)))
    )
    (asserts! (is-eq tx-sender (get certifier certification)) (err u2))
    (ok (map-set quality-certifications
      { certification-id: certification-id }
      (merge certification { passed: passed })
    ))
  )
)

(define-read-only (get-certification (certification-id uint))
  (map-get? quality-certifications { certification-id: certification-id })
)

(define-read-only (get-test-result (certification-id uint) (test-name (string-utf8 100)))
  (map-get? test-results { certification-id: certification-id, test-name: test-name })
)
