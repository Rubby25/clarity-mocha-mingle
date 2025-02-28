;; Constants
(define-constant ERR-NOT-FOUND (err u100))
(define-constant ERR-UNAUTHORIZED (err u101))
(define-constant ERR-INVALID-RATING (err u102))

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
    rating-count: uint
  }
)

(define-map Comments
  uint 
  {
    recipe-id: uint,
    author: principal,
    content: (string-ascii 500)
  }
)

(define-map UserRecipeRatings
  { user: principal, recipe-id: uint }
  uint
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
      rating-count: u0
    })
    (var-set next-recipe-id (+ recipe-id u1))
    (ok recipe-id)
  )
)

(define-public (rate-recipe (recipe-id uint) (rating uint))
  (let (
    (recipe (unwrap! (map-get? Recipes recipe-id) ERR-NOT-FOUND))
    (key { user: tx-sender, recipe-id: recipe-id })
  )
    (asserts! (and (>= rating u1) (<= rating u5)) ERR-INVALID-RATING)
    (map-set Recipes recipe-id (merge recipe {
      total-ratings: (+ (get total-ratings recipe) rating),
      rating-count: (+ (get rating-count recipe) u1)
    }))
    (map-set UserRecipeRatings key rating)
    (ok true)
  )
)

(define-public (add-comment (recipe-id uint) (content (string-ascii 500)))
  (let ((comment-id (var-get next-comment-id)))
    (asserts! (is-some (map-get? Recipes recipe-id)) ERR-NOT-FOUND)
    (map-set Comments comment-id {
      recipe-id: recipe-id,
      author: tx-sender,
      content: content
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
  (ok (unwrap! (map-get? UserRecipeRatings { user: user, recipe-id: recipe-id }) u0))
)
