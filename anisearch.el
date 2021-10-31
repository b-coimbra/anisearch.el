;;; anisearch.el --- An emacs plugin to fetch images from safebooru
;;; Commentary:
;;;

;;; Code:

(require 'request)

(defgroup anisearch nil
  "Config for `anisearch'."
  :group 'applications)

;; User defined variables

(defcustom anisearch-limit 20
  "Number of images to fetch."
  :type 'integer :group 'anisearch)

(defcustom anisearch-tags "megumin"
  "Tags to search with."
  :type 'string :group 'anisearch)

(defcustom anisearch-save-locally 0
  "Whether to save downloaded images locally or not."
  :type 'boolean :group 'anisearch)

;; Internal variables

(defconst anisearch-url "https://safebooru.donmai.us/post/index.json"
  "Safebooru base URL.")

(defvar anisearch--results nil
  "Holds the request results.")

;; Helper routines

(defun anisearch--get-random-image (results)
  "Get a random image from a list of RESULTS."
  (cdr (assoc 'file_url (car (list (aref results (random anisearch-limit)))))))

(defun anisearch--get ()
  "Make a GET request to set the results."
  (request anisearch-url
    :params `(("limit" . ,anisearch-limit)
              ("tags" . ,anisearch-tags))
    :sync t
    :parser 'json-read
    :success (cl-function
              (lambda (&key data &allow-other-keys)
                (setq anisearch--results data))))
  (message "Anisearch: Loaded %s images." (length anisearch--results)))

(defun anisearch--set-results ()
  "Set the request results."
  (if (not anisearch--results)
      (anisearch--get)))

(defun anisearch--save-image (url)
  "Show an image from a URL in a separate buffer. Save temporary FILENAME."
  (shell-command (concat "wget -P downloads/ " url)))

;; Commands

(defun anisearch ()
  "Explosion!"
  (interactive)
  (anisearch--set-results)
  (if (eq (length anisearch--results) 0)
      (message "Anisearch: Unable to search for tag %s" anisearch-tags)
    (let (url)
      (setq url (anisearch--get-random-image anisearch--results))
      (when anisearch-save-locally
        (anisearch--save-image url))
      (browse-url-emacs url))))

(defun anisearch-tag ()
  "Search on safebooru by tag."
  (interactive)
  (setq anisearch-tags (read-string "Tags: "))
  (message "Searching for %s" anisearch-tags)
  (anisearch-clear)
  (anisearch))

(defun anisearch-clear ()
  "Clear the list of loaded images."
  (interactive)
  (setq anisearch--results nil))

;;; anisearch.el ends here
