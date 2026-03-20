(defpackage "PAM/RAW"
  (:use "CL" "CFFI"))

(in-package "PAM/RAW")

(define-foreign-library libpam
  (:darwin "libpam.dylib")
  (:unix "libpam.so"))

(use-foreign-library libpam)

(defmacro define-pam-func (name ret-type &body args)
  (let ((c-name (concatenate 'string "pam_" (translate-underscore-separated-name name))))
    `(eval-when (:compile-toplevel :load-toplevel :execute)
       (defcfun (,c-name ,name) ,ret-type
         ,@args)
       (export ',name))))

(define-pam-func acct-mgmt :int
  (pamh :pointer)
  (flags :int))

(define-pam-func authenticate :int
  (pamh :pointer)
  (flags :int))

(define-pam-func chauthtok :int
  (pamh :pointer)
  (flags :int))

(define-pam-func close-session :int
  (pamh :pointer)
  (flags :int))

(define-pam-func end :int
  (pamh :pointer)
  (status :int))

(define-pam-func get-data :int
  (pamh :pointer)
  (module-data-name :string)
  (data :pointer))

(define-pam-func get-item :int
  (pamh :pointer)
  (item-type :int)
  (item :pointer))

(define-pam-func get-user :int
  (pamh :pointer)
  (user :pointer)
  (prompt :string))

(define-pam-func getenv :string
  (pamh :pointer)
  (name :string))

(define-pam-func getenvlist :pointer
  (pamh :pointer))

(define-pam-func open-session :int
  (pamh :pointer)
  (flags :int))

(define-pam-func putenv :int
  (pamh :pointer)
  (namevalue :string))

(define-pam-func set-data :int
  (pamh :pointer)
  (module-data-name :string)
  (data :pointer)
  (cleanup :pointer))

(define-pam-func set-item :int
  (pamh :pointer)
  (item-type :int)
  (item :pointer))

(define-pam-func setcred :int
  (pamh :pointer)
  (flags :int))

(define-pam-func start :int
  (service :string)
  (user :string)
  (pam-conv :pointer)
  (pamh :pointer))

(define-pam-func strerror :string
  (pamh :pointer)
  (errno :int))

(defcstruct message
  "PAM message structure.

struct pam_message {
    int msg_style;
    char *msg;
};"
  (msg-style :int)
  (msg :string))

(export '(message msg-style msg))

(defcstruct response
  "PAM response structure.

struct pam_response {
    char *resp;
    int resp_retcode;
};"
  (resp :string)
  (resp-retcode :int))

(export '(response resp resp-retcode))

(defcstruct conv
  "PAM conversation structure.

struct pam_conv {
    int (*conv)(int, const struct pam_message **, struct pam_response **, void *);
    void *appdata_ptr;
};"
  (conv :pointer)
  (appdata-ptr :pointer))

(export '(conv appdata-ptr))
