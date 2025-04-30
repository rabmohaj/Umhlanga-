;; Deep Sea Research Funding Protocol Smart Contract - v1.0.0 (MVP)
;; Basic functionality for deep-sea research funding

;; Error Constants
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-STATION-ALREADY-REGISTERED (err u101))
(define-constant ERR-STATION-NOT-REGISTERED (err u102))
(define-constant ERR-RESOURCES-UNAVAILABLE (err u103))
(define-constant ERR-SPONSORSHIP-TOO-SMALL (err u104))

;; Core Program Variables
(define-data-var chief-scientist principal tx-sender)
(define-data-var research-treasury uint u0)
(define-data-var sponsorship-minimum uint u1000000) ;; 1 STX

;; Data Storage
(define-map research-stations 
    principal 
    {
        station-active: bool,
        resources-allocated: uint,
        last-allocation-block: uint
    }
)

(define-map sponsor-registry
    principal
    {
        total-contributions: uint,
        latest-contribution-block: uint
    }
)

;; Read-only Functions
(define-read-only (get-chief-scientist)
    (var-get chief-scientist)
)

(define-read-only (get-research-treasury)
    (var-get research-treasury)
)

(define-read-only (get-station-info (station-address principal))
    (map-get? research-stations station-address)
)

(define-read-only (get-sponsor-info (sponsor-address principal))
    (map-get? sponsor-registry sponsor-address)
)

;; Helper Functions
(define-private (is-chief-scientist)
    (is-eq tx-sender (var-get chief-scientist))
)

(define-private (record-sponsorship (sponsor-address principal) (sponsorship-amount uint))
    (let (
        (sponsor-record (default-to 
            { total-contributions: u0, latest-contribution-block: u0 } 
            (map-get? sponsor-registry sponsor-address)
        ))
    )
    (map-set sponsor-registry
        sponsor-address
        {
            total-contributions: (+ (get total-contributions sponsor-record) sponsorship-amount),
            latest-contribution-block: block-height
        }
    ))
)

;; Public Functions
(define-public (sponsor-deep-sea-research)
    (let (
        (sponsorship-amount (stx-get-balance tx-sender))
    )
    (asserts! (>= sponsorship-amount (var-get sponsorship-minimum)) ERR-SPONSORSHIP-TOO-SMALL)
    
    (try! (stx-transfer? sponsorship-amount tx-sender (as-contract tx-sender)))
    (var-set research-treasury (+ (var-get research-treasury) sponsorship-amount))
    (record-sponsorship tx-sender sponsorship-amount)
    (ok sponsorship-amount))
)

;; Station Management
(define-public (register-research-station (station-address principal))
    (begin
        (asserts! (is-chief-scientist) ERR-NOT-AUTHORIZED)
        (asserts! (is-none (map-get? research-stations station-address)) ERR-STATION-ALREADY-REGISTERED)
        
        (map-set research-stations 
            station-address
            {
                station-active: true,
                resources-allocated: u0,
                last-allocation-block: u0
            }
        )
        (ok true)
    )
)

(define-public (allocate-resources (station-address principal) (resource-amount uint))
    (begin
        (asserts! (is-chief-scientist) ERR-NOT-AUTHORIZED)
        (asserts! (>= (var-get research-treasury) resource-amount) ERR-RESOURCES-UNAVAILABLE)
        (asserts! 
            (is-some (map-get? research-stations station-address)) 
            ERR-STATION-NOT-REGISTERED
        )
        
        (try! (as-contract (stx-transfer? resource-amount tx-sender station-address)))
        (var-set research-treasury (- (var-get research-treasury) resource-amount))
        
        (let (
            (station-info (unwrap! (map-get? research-stations station-address) ERR-STATION-NOT-REGISTERED))
        )
        (map-set research-stations
            station-address
            {
                station-active: (get station-active station-info),
                resources-allocated: (+ (get resources-allocated station-info) resource-amount),
                last-allocation-block: block-height
            }
        )
        (ok resource-amount))
    )
)

;; Administrative Functions
(define-public (set-sponsorship-minimum (new-minimum uint))
    (begin
        (asserts! (is-chief-scientist) ERR-NOT-AUTHORIZED)
        (var-set sponsorship-minimum new-minimum)
        (ok true)
    )
)

;; Governance Function
(define-public (change-chief-scientist (new-chief-scientist-address principal))
    (begin
        (asserts! (is-chief-scientist) ERR-NOT-AUTHORIZED)
        (var-set chief-scientist new-chief-scientist-address)
        (ok true)
    )
)