;; Habit Builder Smart Contract - Wellness/Health Theme
;; Build habits, track streaks, earn wellness badges

;; Constants
(define-constant wellness-coach tx-sender)
(define-constant err-not-coach (err u100))
(define-constant err-habit-not-found (err u101))
(define-constant err-habit-already-tracked (err u102))
(define-constant err-not-participant (err u103))
(define-constant err-invalid-habit (err u104))

;; Data Variables
(define-data-var habit-sequence uint u0)
(define-data-var wellness-badge-sequence uint u0)

;; Data Maps
;; Store habit tracking data
(define-map habits 
    { habit-id: uint, participant: principal }
    { 
        habit-name: (string-utf8 256),
        routine-details: (string-utf8 1024),
        tracked: bool,
        started-on: uint,
        tracked-on: (optional uint)
    }
)

;; Track participant wellness journey
(define-map participant-journey
    principal
    {
        total-habits: uint,
        tracked-habits: uint,
        current-habits: uint
    }
)

;; NFT Wellness Badges
(define-non-fungible-token wellness-badge uint)

;; Map to track wellness achievements
(define-map wellness-achievements
    { participant: principal, badge-name: (string-ascii 50) }
    { achieved: bool, achieved-on: uint }
)

;; Helper Functions
(define-private (next-habit-id)
    (let ((current-seq (var-get habit-sequence)))
        (var-set habit-sequence (+ current-seq u1))
        current-seq
    )
)

(define-private (next-badge-id)
    (let ((current-seq (var-get wellness-badge-sequence)))
        (var-set wellness-badge-sequence (+ current-seq u1))
        current-seq
    )
)

;; Read-only Functions
(define-read-only (check-habit (habit-id uint) (participant principal))
    (map-get? habits { habit-id: habit-id, participant: participant })
)

(define-read-only (view-journey (participant principal))
    (default-to 
        { total-habits: u0, tracked-habits: u0, current-habits: u0 }
        (map-get? participant-journey participant)
    )
)

(define-read-only (has-wellness-badge (participant principal) (badge-name (string-ascii 50)))
    (default-to 
        { achieved: false, achieved-on: u0 }
        (map-get? wellness-achievements { participant: participant, badge-name: badge-name })
    )
)

;; Private Functions
(define-private (update-journey-stats (participant principal) (is-start bool) (is-track bool))
    (let ((current-journey (view-journey participant)))
        (if is-start
            ;; Starting a new habit
            (map-set participant-journey participant {
                total-habits: (+ (get total-habits current-journey) u1),
                tracked-habits: (get tracked-habits current-journey),
                current-habits: (+ (get current-habits current-journey) u1)
            })
            (if is-track
                ;; Tracking a habit
                (map-set participant-journey participant {
                    total-habits: (get total-habits current-journey),
                    tracked-habits: (+ (get tracked-habits current-journey) u1),
                    current-habits: (- (get current-habits current-journey) u1)
                })
                ;; Stopping a habit
                (map-set participant-journey participant {
                    total-habits: (get total-habits current-journey),
                    tracked-habits: (get tracked-habits current-journey),
                    current-habits: (- (get current-habits current-journey) u1)
                })
            )
        )
    )
)

(define-private (evaluate-wellness-milestones (participant principal))
    (let (
        (journey (view-journey participant))
        (tracked (get tracked-habits journey))
    )
        ;; Check wellness milestones
        (begin
            ;; First step badge
            (and (is-eq tracked u1) 
                 (not (get achieved (has-wellness-badge participant "first-step")))
                 (is-ok (award-wellness-badge participant "first-step")))
            ;; Committed badge for 10 habits
            (and (>= tracked u10) 
                 (not (get achieved (has-wellness-badge participant "committed-10")))
                 (is-ok (award-wellness-badge participant "committed-10")))
            ;; Dedicated badge for 50 habits
            (and (>= tracked u50) 
                 (not (get achieved (has-wellness-badge participant "dedicated-50")))
                 (is-ok (award-wellness-badge participant "dedicated-50")))
            ;; Wellness master for 100 habits
            (and (>= tracked u100) 
                 (not (get achieved (has-wellness-badge participant "wellness-master")))
                 (is-ok (award-wellness-badge participant "wellness-master")))
            true
        )
    )
)

(define-private (award-wellness-badge (participant principal) (badge-name (string-ascii 50)))
    (let ((badge-id (next-badge-id)))
        (map-set wellness-achievements 
            { participant: participant, badge-name: badge-name }
            { achieved: true, achieved-on: block-height }
        )
        (nft-mint? wellness-badge badge-id participant)
    )
)

;; Public Functions
(define-public (start-habit (habit-name (string-utf8 256)) (routine-details (string-utf8 1024)))
    (let (
        (habit-id (next-habit-id))
        (participant tx-sender)
    )
        (if (or (is-eq (len habit-name) u0) (> (len habit-name) u256) (> (len routine-details) u1024))
            err-invalid-habit
            (begin
                (map-set habits 
                    { habit-id: habit-id, participant: participant }
                    {
                        habit-name: habit-name,
                        routine-details: routine-details,
                        tracked: false,
                        started-on: block-height,
                        tracked-on: none
                    }
                )
                (update-journey-stats participant true false)
                (ok habit-id)
            )
        )
    )
)

(define-public (track-habit (habit-id uint))
    (let (
        (habit-key { habit-id: habit-id, participant: tx-sender })
        (habit (map-get? habits habit-key))
    )
        (match habit
            habit-data
            (if (get tracked habit-data)
                err-habit-already-tracked
                (begin
                    (map-set habits habit-key
                        (merge habit-data {
                            tracked: true,
                            tracked-on: (some block-height)
                        })
                    )
                    (update-journey-stats tx-sender false true)
                    (evaluate-wellness-milestones tx-sender)
                    (ok true)
                )
            )
            err-habit-not-found
        )
    )
)

(define-public (stop-habit (habit-id uint))
    (let (
        (habit-key { habit-id: habit-id, participant: tx-sender })
        (habit (map-get? habits habit-key))
    )
        (match habit
            habit-data
            (begin
                (map-delete habits habit-key)
                (if (not (get tracked habit-data))
                    (update-journey-stats tx-sender false false)
                    true
                )
                (ok true)
            )
            err-habit-not-found
        )
    )
)

;; Adjust habit details
(define-public (adjust-habit (habit-id uint) (habit-name (string-utf8 256)) (routine-details (string-utf8 1024)))
    (let (
        (habit-key { habit-id: habit-id, participant: tx-sender })
        (habit (map-get? habits habit-key))
    )
        (match habit
            habit-data
            (if (get tracked habit-data)
                err-habit-already-tracked
                (if (or (is-eq (len habit-name) u0) (> (len habit-name) u256) (> (len routine-details) u1024))
                    err-invalid-habit
                    (begin
                        (map-set habits habit-key
                            (merge habit-data {
                                habit-name: habit-name,
                                routine-details: routine-details
                            })
                        )
                        (ok true)
                    )
                )
            )
            err-habit-not-found
        )
    )
)

;; Check if habit exists
(define-read-only (habit-registered (habit-id uint) (participant principal))
    (is-some (map-get? habits { habit-id: habit-id, participant: participant }))
)