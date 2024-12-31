;; TokenGovernance: A token-based governance system

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u100))
(define-constant ERR_ALREADY_SUBMITTED (err u101))
(define-constant ERR_MOTION_NOT_FOUND (err u102))
(define-constant ERR_MOTION_EXPIRED (err u103))
(define-constant ERR_INVALID_NAME (err u104))
(define-constant ERR_INVALID_DETAILS (err u105))
(define-constant ERR_INVALID_TIMEFRAME (err u106))

;; Data maps
(define-map motions
  { motion-id: uint }
  { 
    name: (string-ascii 50),
    details: (string-ascii 280),
    submitter: principal,
    approve-count: uint,
    reject-count: uint,
    expiry-block: uint
  }
)

(define-map decisions
  { participant: principal, motion-id: uint }
  { decision: bool }
)

;; Variables
(define-data-var motion-counter uint u0)

;; Read-only functions
(define-read-only (get-motion (motion-id uint))
  (map-get? motions { motion-id: motion-id })
)

(define-read-only (get-decision (participant principal) (motion-id uint))
  (map-get? decisions { participant: participant, motion-id: motion-id })
)

(define-read-only (is-motion-active (motion-id uint))
  (let ((motion (unwrap! (get-motion motion-id) false)))
    (< block-height (get expiry-block motion))
  )
)

;; Private functions
(define-private (validate-text-length (text (string-ascii 280)) (min uint) (max uint))
  (let ((len (len text)))
    (and (>= len min) (<= len max))
  )
)

;; Public functions
(define-public (submit-motion (name (string-ascii 50)) (details (string-ascii 280)) (timeframe uint))
  (let
    (
      (new-motion-id (+ (var-get motion-counter) u1))
      (expiry-block (+ block-height timeframe))
    )
    ;; Input validation
    (asserts! (validate-text-length name u1 u50) ERR_INVALID_NAME)
    (asserts! (validate-text-length details u1 u280) ERR_INVALID_DETAILS)
    (asserts! (and (> timeframe u0) (<= timeframe u10000)) ERR_INVALID_TIMEFRAME)
    
    (map-set motions
      { motion-id: new-motion-id }
      {
        name: name,
        details: details,
        submitter: tx-sender,
        approve-count: u0,
        reject-count: u0,
        expiry-block: expiry-block
      }
    )
    (var-set motion-counter new-motion-id)
    (ok new-motion-id)
  )
)

(define-public (cast-vote (motion-id uint) (approve-bool bool))
  (let
    (
      (motion (unwrap! (get-motion motion-id) ERR_MOTION_NOT_FOUND))
    )
    (asserts! (is-motion-active motion-id) ERR_MOTION_EXPIRED)
    (asserts! (is-none (get-decision tx-sender motion-id)) ERR_ALREADY_SUBMITTED)
    (map-set decisions
      { participant: tx-sender, motion-id: motion-id }
      { decision: approve-bool }
    )
    (if approve-bool
      (map-set motions
        { motion-id: motion-id }
        (merge motion { approve-count: (+ (get approve-count motion) u1) })
      )
      (map-set motions
        { motion-id: motion-id }
        (merge motion { reject-count: (+ (get reject-count motion) u1) })
      )
    )
    (ok true)
  )
)

;; Admin functions
(define-public (end-motion (motion-id uint))
  (let
    (
      (motion (unwrap! (get-motion motion-id) ERR_MOTION_NOT_FOUND))
    )
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (asserts! (>= block-height (get expiry-block motion)) ERR_MOTION_EXPIRED)
    (map-set motions
      { motion-id: motion-id }
      (merge motion { expiry-block: block-height })
    )
    (ok true)
  )
)