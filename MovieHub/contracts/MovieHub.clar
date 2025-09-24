;; MovieHub - Digital Film Community Platform
;; A blockchain-based platform for movie reviews, watchlists,
;; and cinema community rewards

;; Contract constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-unauthorized (err u103))
(define-constant err-invalid-input (err u104))

;; Token constants
(define-constant token-name "MovieHub Cinema Token")
(define-constant token-symbol "MCT")
(define-constant token-decimals u6)
(define-constant token-max-supply u40000000000) ;; 40k tokens with 6 decimals

;; Reward amounts (in micro-tokens)
(define-constant reward-watch u1400000) ;; 1.4 MCT
(define-constant reward-review u2600000) ;; 2.6 MCT
(define-constant reward-milestone u8500000) ;; 8.5 MCT

;; Data variables
(define-data-var total-supply uint u0)
(define-data-var next-movie-id uint u1)
(define-data-var next-watch-id uint u1)

;; Token balances
(define-map token-balances principal uint)

;; Viewer profiles
(define-map viewer-profiles
  principal
  {
    username: (string-ascii 24),
    favorite-genre: (string-ascii 12), ;; "action", "comedy", "drama", "horror", "sci-fi"
    movies-watched: uint,
    reviews-written: uint,
    watchlist-items: uint,
    viewer-level: uint, ;; 1-5
    join-date: uint
  }
)

;; Movie database
(define-map movie-database
  uint
  {
    movie-title: (string-ascii 48),
    genre: (string-ascii 12),
    release-year: uint,
    runtime-minutes: uint,
    director: (string-ascii 24),
    submitter: principal,
    watch-count: uint,
    average-rating: uint
  }
)

;; Watch sessions
(define-map watch-sessions
  uint
  {
    movie-id: uint,
    viewer: principal,
    watch-rating: uint, ;; 1-10
    watch-location: (string-ascii 12), ;; "theater", "home", "streaming"
    watch-notes: (string-ascii 96),
    watch-date: uint,
    recommended: bool
  }
)

;; Movie reviews
(define-map movie-reviews
  { movie-id: uint, reviewer: principal }
  {
    rating: uint, ;; 1-10
    review-text: (string-ascii 200),
    spoiler-free: bool,
    review-date: uint,
    upvotes: uint
  }
)

;; Viewer milestones
(define-map viewer-milestones
  { viewer: principal, milestone: (string-ascii 12) }
  {
    achievement-date: uint,
    movie-count: uint
  }
)

;; Helper function to get or create profile
(define-private (get-or-create-profile (viewer principal))
  (match (map-get? viewer-profiles viewer)
    profile profile
    {
      username: "",
      favorite-genre: "drama",
      movies-watched: u0,
      reviews-written: u0,
      watchlist-items: u0,
      viewer-level: u1,
      join-date: stacks-block-height
    }
  )
)

;; Token functions
(define-read-only (get-name)
  (ok token-name)
)

(define-read-only (get-symbol)
  (ok token-symbol)
)

(define-read-only (get-decimals)
  (ok token-decimals)
)

(define-read-only (get-balance (user principal))
  (ok (default-to u0 (map-get? token-balances user)))
)

(define-private (mint-tokens (recipient principal) (amount uint))
  (let (
    (current-balance (default-to u0 (map-get? token-balances recipient)))
    (new-balance (+ current-balance amount))
    (new-total-supply (+ (var-get total-supply) amount))
  )
    (asserts! (<= new-total-supply token-max-supply) err-invalid-input)
    (map-set token-balances recipient new-balance)
    (var-set total-supply new-total-supply)
    (ok amount)
  )
)

;; Add movie to database
(define-public (add-movie (movie-title (string-ascii 48)) (genre (string-ascii 12)) (release-year uint) (runtime-minutes uint) (director (string-ascii 24)))
  (let (
    (movie-id (var-get next-movie-id))
  )
    (asserts! (> (len movie-title) u0) err-invalid-input)
    (asserts! (> (len director) u0) err-invalid-input)
    (asserts! (> runtime-minutes u0) err-invalid-input)
    (asserts! (>= release-year u1900) err-invalid-input)
    
    (map-set movie-database movie-id {
      movie-title: movie-title,
      genre: genre,
      release-year: release-year,
      runtime-minutes: runtime-minutes,
      director: director,
      submitter: tx-sender,
      watch-count: u0,
      average-rating: u0
    })
    
    (var-set next-movie-id (+ movie-id u1))
    (print {action: "movie-added", movie-id: movie-id, submitter: tx-sender})
    (ok movie-id)
  )
)

;; Log watch session
(define-public (log-watch (movie-id uint) (watch-rating uint) (watch-location (string-ascii 12)) (watch-notes (string-ascii 96)))
  (let (
    (watch-id (var-get next-watch-id))
    (movie (unwrap! (map-get? movie-database movie-id) err-not-found))
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (and (>= watch-rating u1) (<= watch-rating u10)) err-invalid-input)
    
    (map-set watch-sessions watch-id {
      movie-id: movie-id,
      viewer: tx-sender,
      watch-rating: watch-rating,
      watch-location: watch-location,
      watch-notes: watch-notes,
      watch-date: stacks-block-height,
      recommended: (>= watch-rating u7)
    })
    
    ;; Update movie watch count
    (map-set movie-database movie-id
      (merge movie {watch-count: (+ (get watch-count movie) u1)})
    )
    
    ;; Update profile
    (map-set viewer-profiles tx-sender
      (merge profile {
        movies-watched: (+ (get movies-watched profile) u1),
        viewer-level: (+ (get viewer-level profile) (/ watch-rating u20))
      })
    )
    
    ;; Award watch tokens
    (try! (mint-tokens tx-sender reward-watch))
    
    (var-set next-watch-id (+ watch-id u1))
    (print {action: "watch-logged", watch-id: watch-id, movie-id: movie-id})
    (ok watch-id)
  )
)

;; Write movie review
(define-public (write-review (movie-id uint) (rating uint) (review-text (string-ascii 200)) (spoiler-free bool))
  (let (
    (movie (unwrap! (map-get? movie-database movie-id) err-not-found))
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (and (>= rating u1) (<= rating u10)) err-invalid-input)
    (asserts! (> (len review-text) u0) err-invalid-input)
    (asserts! (is-none (map-get? movie-reviews {movie-id: movie-id, reviewer: tx-sender})) err-already-exists)
    
    (map-set movie-reviews {movie-id: movie-id, reviewer: tx-sender} {
      rating: rating,
      review-text: review-text,
      spoiler-free: spoiler-free,
      review-date: stacks-block-height,
      upvotes: u0
    })
    
    ;; Update movie average rating (simplified calculation)
    (let (
      (current-avg (get average-rating movie))
      (watch-count (get watch-count movie))
      (new-avg (if (> watch-count u0)
                 (/ (+ (* current-avg watch-count) rating) (+ watch-count u1))
                 rating))
    )
      (map-set movie-database movie-id (merge movie {average-rating: new-avg}))
    )
    
    ;; Update profile
    (map-set viewer-profiles tx-sender
      (merge profile {reviews-written: (+ (get reviews-written profile) u1)})
    )
    
    ;; Award review tokens
    (try! (mint-tokens tx-sender reward-review))
    
    (print {action: "review-written", movie-id: movie-id, reviewer: tx-sender})
    (ok true)
  )
)

;; Upvote review
(define-public (upvote-review (movie-id uint) (reviewer principal))
  (let (
    (review (unwrap! (map-get? movie-reviews {movie-id: movie-id, reviewer: reviewer}) err-not-found))
  )
    (asserts! (not (is-eq tx-sender reviewer)) err-unauthorized)
    
    (map-set movie-reviews {movie-id: movie-id, reviewer: reviewer}
      (merge review {upvotes: (+ (get upvotes review) u1)})
    )
    
    (print {action: "review-upvoted", movie-id: movie-id, reviewer: reviewer})
    (ok true)
  )
)

;; Update favorite genre
(define-public (update-favorite-genre (new-favorite-genre (string-ascii 12)))
  (let (
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (> (len new-favorite-genre) u0) err-invalid-input)
    
    (map-set viewer-profiles tx-sender (merge profile {favorite-genre: new-favorite-genre}))
    
    (print {action: "favorite-genre-updated", viewer: tx-sender, genre: new-favorite-genre})
    (ok true)
  )
)

;; Claim milestone
(define-public (claim-milestone (milestone (string-ascii 12)))
  (let (
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (is-none (map-get? viewer-milestones {viewer: tx-sender, milestone: milestone})) err-already-exists)
    
    ;; Check milestone requirements
    (let (
      (milestone-met
        (if (is-eq milestone "cinephile-25") (>= (get movies-watched profile) u25)
        (if (is-eq milestone "critic-12") (>= (get reviews-written profile) u12)
        false)))
    )
      (asserts! milestone-met err-unauthorized)
      
      ;; Record milestone
      (map-set viewer-milestones {viewer: tx-sender, milestone: milestone} {
        achievement-date: stacks-block-height,
        movie-count: (get movies-watched profile)
      })
      
      ;; Award milestone tokens
      (try! (mint-tokens tx-sender reward-milestone))
      
      (print {action: "milestone-claimed", viewer: tx-sender, milestone: milestone})
      (ok true)
    )
  )
)

;; Update username
(define-public (update-username (new-username (string-ascii 24)))
  (let (
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (> (len new-username) u0) err-invalid-input)
    (map-set viewer-profiles tx-sender (merge profile {username: new-username}))
    (print {action: "username-updated", viewer: tx-sender})
    (ok true)
  )
)

;; Read-only functions
(define-read-only (get-viewer-profile (viewer principal))
  (map-get? viewer-profiles viewer)
)

(define-read-only (get-movie (movie-id uint))
  (map-get? movie-database movie-id)
)

(define-read-only (get-watch-session (watch-id uint))
  (map-get? watch-sessions watch-id)
)

(define-read-only (get-movie-review (movie-id uint) (reviewer principal))
  (map-get? movie-reviews {movie-id: movie-id, reviewer: reviewer})
)

(define-read-only (get-milestone (viewer principal) (milestone (string-ascii 12)))
  (map-get? viewer-milestones {viewer: viewer, milestone: milestone})
)