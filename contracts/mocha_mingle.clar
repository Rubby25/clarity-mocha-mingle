;; Constants
(define-constant ERR-NOT-FOUND (err u100))
(define-constant ERR-UNAUTHORIZED (err u101))
(define-constant ERR-INVALID-RATING (err u102))
(define-constant ERR-ALREADY-RATED (err u103))
(define-constant ERR-INVALID-STATUS (err u104))

;; Data variables
(define-data-var next-recipe-id uint u1)
(define-data-var next-comment-id uint u1)

;; Data maps
(define-map Recipes 
  uint 
  {
    title: (string-ascii 100),
    content: (string-ascii 1000),
    author: principal,
    difficulty: uint,
    total-ratings: uint,
    rating-count: uint,
    status: (string-ascii 20),
    created-at: uint,
    updated-at: uint
  }
)

(define-map Comments
  uint 
  {
    recipe-id: uint,
    author: principal,
    content: (string-ascii 500),
    created-at: uint
  }
)

(define-map UserRecipeRatings
  { user: principal, recipe-id: uint }
  { rating: uint, last-updated: uint }
)

;; Public functions
(define-public (create-recipe (title (string-ascii 100)) (content (string-ascii 1000)) (difficulty uint))
  (let ((recipe-id (var-get next-recipe-id)))
    (map-set Recipes recipe-id {
      title: title,
      content: content,
      author: tx-sender,
      difficulty: difficulty,
      total-ratings: u0,
      rating-count: u0,
      status: "active",
      created-at: block-height,
      updated-at: block-height
    })
    (var-set next-recipe-id (+ recipe-id u1))
    (ok recipe-id)
  )
)

(define-public (update-recipe (recipe-id uint) (title (string-ascii 100)) (content (string-ascii 1000)) (difficulty uint))
  (let ((recipe (unwrap! (map-get? Recipes recipe-id) ERR-NOT-FOUND)))
    (asserts! (is-eq tx-sender (get author recipe)) ERR-UNAUTHORIZED)
    (map-set Recipes recipe-id (merge recipe {
      title: title,
      content: content,
      difficulty: difficulty,
      updated-at: block-height
    }))
    (ok true)
  )
)

(define-public (delete-recipe (recipe-id uint))
  (let ((recipe (unwrap! (map-get? Recipes recipe-id) ERR-NOT-FOUND)))
    (asserts! (is-eq tx-sender (get author recipe)) ERR-UNAUTHORIZED)
    (map-set Recipes recipe-id (merge recipe {
      status: "deleted",
      updated-at: block-height
    }))
    (ok true)
  )
)

(define-public (rate-recipe (recipe-id uint) (rating uint))
  (let (
    (recipe (unwrap! (map-get? Recipes recipe-id) ERR-NOT-FOUND))
    (key { user: tx-sender, recipe-id: recipe-id })
    (existing-rating (map-get? UserRecipeRatings key))
  )
    (asserts! (and (>= rating u1) (<= rating u5)) ERR-INVALID-RATING)
    (if (is-some existing-rating)
      (let ((old-rating (get rating (unwrap-panic existing-rating))))
        (map-set Recipes recipe-id (merge recipe {
          total-ratings: (+ (- (get total-ratings recipe) old-rating) rating)
        }))
      )
      (map-set Recipes recipe-id (merge recipe {
        total-ratings: (+ (get total-ratings recipe) rating),
        rating-count: (+ (get rating-count recipe) u1)
      }))
    )
    (map-set UserRecipeRatings key { rating: rating, last-updated: block-height })
    (ok true)
  )
)

(define-public (add-comment (recipe-id uint) (content (string-ascii 500)))
  (let ((comment-id (var-get next-comment-id)))
    (asserts! (is-some (map-get? Recipes recipe-id)) ERR-NOT-FOUND)
    (map-set Comments comment-id {
      recipe-id: recipe-id,
      author: tx-sender,
      content: content,
      created-at: block-height
    })
    (var-set next-comment-id (+ comment-id u1))
    (ok comment-id)
  )
)

;; Read only functions
(define-read-only (get-recipe (recipe-id uint))
  (ok (unwrap! (map-get? Recipes recipe-id) ERR-NOT-FOUND))
)

(define-read-only (get-comment (comment-id uint))
  (ok (unwrap! (map-get? Comments comment-id) ERR-NOT-FOUND))
)

(define-read-only (get-rating (user principal) (recipe-id uint))
  (ok (get rating (unwrap! (map-get? UserRecipeRatings { user: user, recipe-id: recipe-id }) { rating: u0, last-updated: u0 })))
)

(define-read-only (get-average-rating (recipe-id uint))
  (let ((recipe (unwrap! (map-get? Recipes recipe-id) ERR-NOT-FOUND)))
    (ok (if (is-eq (get rating-count recipe) u0)
      u0
      (/ (get total-ratings recipe) (get rating-count recipe))))
  )
)
