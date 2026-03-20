(defpackage "PAM"
  (:use "CL" "CFFI")
  (:import-from "PAM/RAW"
                "MESSAGE" "MSG" "MSG-STYLE"
                "RESPONSE" "RESP" "RESP-RETCODE"
                "CONV" "APPDATA-PTR")
  (:export
   ;; Condition
   #:pam-error
   #:pam-error-pamh
   #:pam-error-func
   #:pam-error-args
   #:pam-error-errno
   ;; Return values (common)
   #:+success+
   #:+open-err+
   #:+symbol-err+
   #:+service-err+
   #:+system-err+
   #:+buf-err+
   #:+perm-denied+
   #:+auth-err+
   #:+cred-insufficient+
   #:+authinfo-unavail+
   #:+user-unknown+
   #:+maxtries+
   #:+new-authtok-reqd+
   #:+acct-expired+
   #:+session-err+
   #:+cred-unavail+
   #:+cred-expired+
   #:+cred-err+
   #:+no-module-data+
   #:+conv-err+
   #:+authtok-err+
   #:+authtok-recovery-err+
   #:+authtok-lock-busy+
   #:+authtok-disable-aging+
   #:+try-again+
   #:+ignore+
   #:+abort+
   #:+authtok-expired+
   #:+module-unknown+
   ;; Return values (Linux-PAM only)
   #+linux #:+bad-item+
   #+linux #:+conv-again+
   #+linux #:+incomplete+
   ;; Return values (OpenPAM only)
   #-linux #:+domain-unknown+
   ;; Return values (Apple OpenPAM only)
   #+darwin #:+apple-acct-temp-lock+
   #+darwin #:+apple-acct-locked+
   #+darwin #:+apple-kek-error+
   #+darwin #:+apple-wrong-card+
   ;; Flags (common)
   #:+silent+
   #:+disallow-null-authtok+
   #:+establish-cred+
   #:+delete-cred+
   #:+reinitialize-cred+
   #:+refresh-cred+
   #:+change-expired-authtok+
   ;; Flags (Linux-PAM only)
   #+linux #:+data-silent+
   ;; Flags (OpenPAM only)
   #-linux #:+prelim-check+
   #-linux #:+update-authtok+
   ;; Item types (common)
   #:+service+
   #:+user+
   #:+tty+
   #:+rhost+
   #:+conv+
   #:+authtok+
   #:+oldauthtok+
   #:+ruser+
   #:+user-prompt+
   ;; Item types (Linux-PAM only)
   #+linux #:+fail-delay+
   #+linux #:+xdisplay+
   #+linux #:+xauthdata+
   #+linux #:+authtok-type+
   ;; Item types (OpenPAM only)
   #-linux #:+repository+
   #-linux #:+authtok-prompt+
   #-linux #:+oldauthtok-prompt+
   ;; Conversation (common)
   #:+prompt-echo-off+
   #:+prompt-echo-on+
   #:+error-msg+
   #:+text-info+
   #:+max-msg-size+
   #:+max-resp-size+
   ;; Conversation (Linux-PAM only)
   #+linux #:+radio-type+
   #+linux #:+binary-prompt+
   #+linux #:+num-msg+
   ;; Conversation (OpenPAM only)
   #-linux #:+max-num-msg+
   ;; Functions
   #:item-foreign-type
   ;; Handle metaclass and MOP support
   #:handle-class
   #:handle-slot
   #:handle-direct-slot
   #:handle-slot-item-type
   ;; Handle class
   #:handle
   ;; Handle accessors (common)
   #:handle-object
   #:handle-status
   #:handle-service
   #:handle-user
   #:handle-tty
   #:handle-rhost
   #:handle-conv
   #:handle-authtok
   #:handle-oldauthtok
   #:handle-ruser
   #:handle-user-prompt
   ;; Handle accessors (Linux-PAM only)
   #+linux #:handle-fail-delay
   #+linux #:handle-xdisplay
   #+linux #:handle-xauthdata
   #+linux #:handle-authtok-type
   ;; Handle accessors (OpenPAM only)
   #-linux #:handle-repository
   #-linux #:handle-authtok-prompt
   #-linux #:handle-oldauthtok-prompt
   ;; PAM API
   #:start
   #:end
   #:acct-mgmt
   #:authenticate
   #:setcred
   #:chauthtok
   #:open-session
   #:close-session
   #:getenv
   #:putenv
   #:getenvlist))

(in-package "PAM")

;;; Foreign library

(define-foreign-library libpam
  (:darwin "libpam.dylib")
  (:unix "libpam.so"))

(use-foreign-library libpam)

(define-condition pam-error (error)
  ((pamh :initarg :pamh
         :reader pam-error-pamh)
   (func :initarg :func
         :reader pam-error-func)
   (args :initarg :args
         :reader pam-error-args)
   (errno :initarg :errno
          :reader pam-error-errno))
  (:report (lambda (condition stream)
             (format stream "~A(~{~A~^, ~}): ~A"
                     (pam-error-func condition)
                     (pam-error-args condition)
                     (pam/raw:strerror (pam-error-pamh condition)
                                       (pam-error-errno condition))))))

#+linux
(eval-when (:compile-toplevel :load-toplevel :execute)

;;; Linux-PAM return values

  (defconstant +success+ 0)
  (defconstant +open-err+ 1)
  (defconstant +symbol-err+ 2)
  (defconstant +service-err+ 3)
  (defconstant +system-err+ 4)
  (defconstant +buf-err+ 5)
  (defconstant +perm-denied+ 6)
  (defconstant +auth-err+ 7)
  (defconstant +cred-insufficient+ 8)
  (defconstant +authinfo-unavail+ 9)
  (defconstant +user-unknown+ 10)
  (defconstant +maxtries+ 11)
  (defconstant +new-authtok-reqd+ 12)
  (defconstant +acct-expired+ 13)
  (defconstant +session-err+ 14)
  (defconstant +cred-unavail+ 15)
  (defconstant +cred-expired+ 16)
  (defconstant +cred-err+ 17)
  (defconstant +no-module-data+ 18)
  (defconstant +conv-err+ 19)
  (defconstant +authtok-err+ 20)
  (defconstant +authtok-recovery-err+ 21)
  (defconstant +authtok-lock-busy+ 22)
  (defconstant +authtok-disable-aging+ 23)
  (defconstant +try-again+ 24)
  (defconstant +ignore+ 25)
  (defconstant +abort+ 26)
  (defconstant +authtok-expired+ 27)
  (defconstant +module-unknown+ 28)
  (defconstant +bad-item+ 29)
  (defconstant +conv-again+ 30)
  (defconstant +incomplete+ 31)

;;; Linux-PAM flags

  (defconstant +silent+ #x8000)
  (defconstant +disallow-null-authtok+ #x0001)
  (defconstant +establish-cred+ #x0002)
  (defconstant +delete-cred+ #x0004)
  (defconstant +reinitialize-cred+ #x0008)
  (defconstant +refresh-cred+ #x0010)
  (defconstant +change-expired-authtok+ #x0020)

  (defconstant +data-silent+ #x40000000)

;;; Linux-PAM item types

  (defconstant +service+ 1)
  (defconstant +user+ 2)
  (defconstant +tty+ 3)
  (defconstant +rhost+ 4)
  (defconstant +conv+ 5)
  (defconstant +authtok+ 6)
  (defconstant +oldauthtok+ 7)
  (defconstant +ruser+ 8)
  (defconstant +user-prompt+ 9)
  (defconstant +fail-delay+ 10)
  (defconstant +xdisplay+ 11)
  (defconstant +xauthdata+ 12)
  (defconstant +authtok-type+ 13)

;;; Linux-PAM conversation

  (defconstant +prompt-echo-off+ 1)
  (defconstant +prompt-echo-on+ 2)
  (defconstant +error-msg+ 3)
  (defconstant +text-info+ 4)
  (defconstant +radio-type+ 5)
  (defconstant +binary-prompt+ 7)
  (defconstant +num-msg+ 32)
  (defconstant +max-msg-size+ 512)
  (defconstant +max-resp-size+ 512)
  )

#-linux
(eval-when (:compile-toplevel :load-toplevel :execute)

;;; OpenPAM return values

  (defconstant +success+ 0)
  (defconstant +open-err+ 1)
  (defconstant +symbol-err+ 2)
  (defconstant +service-err+ 3)
  (defconstant +system-err+ 4)
  (defconstant +buf-err+ 5)
  (defconstant +conv-err+ 6)
  (defconstant +perm-denied+ 7)
  (defconstant +maxtries+ 8)
  (defconstant +auth-err+ 9)
  (defconstant +new-authtok-reqd+ 10)
  (defconstant +cred-insufficient+ 11)
  (defconstant +authinfo-unavail+ 12)
  (defconstant +user-unknown+ 13)
  (defconstant +cred-unavail+ 14)
  (defconstant +cred-expired+ 15)
  (defconstant +cred-err+ 16)
  (defconstant +acct-expired+ 17)
  (defconstant +authtok-expired+ 18)
  (defconstant +session-err+ 19)
  (defconstant +authtok-err+ 20)
  (defconstant +authtok-recovery-err+ 21)
  (defconstant +authtok-lock-busy+ 22)
  (defconstant +authtok-disable-aging+ 23)
  (defconstant +no-module-data+ 24)
  (defconstant +ignore+ 25)
  (defconstant +abort+ 26)
  (defconstant +try-again+ 27)
  (defconstant +module-unknown+ 28)
  (defconstant +domain-unknown+ 29)

;;; Custom Apple OpenPAM error codes, updated to Tahoe 26.3

  #+darwin
  (progn
    (defconstant +apple-acct-temp-lock+ 1024)
    (defconstant +apple-acct-locked+ 1025)
    (defconstant +apple-kek-error+ 1026)
    (defconstant +apple-wrong-card+ 1027))

;;; OpenPAM flags

  (defconstant +silent+ (- #x7fffffff 1))
  (defconstant +disallow-null-authtok+ #x1)
  (defconstant +establish-cred+ #x1)
  (defconstant +delete-cred+ #x2)
  (defconstant +reinitialize-cred+ #x4)
  (defconstant +refresh-cred+ #x8)
  (defconstant +prelim-check+ #x1)
  (defconstant +update-authtok+ #x2)
  (defconstant +change-expired-authtok+ #x4)

;;; OpenPAM item types

  (defconstant +service+ 1)
  (defconstant +user+ 2)
  (defconstant +tty+ 3)
  (defconstant +rhost+ 4)
  (defconstant +conv+ 5)
  (defconstant +authtok+ 6)
  (defconstant +oldauthtok+ 7)
  (defconstant +ruser+ 8)
  (defconstant +user-prompt+ 9)
  (defconstant +repository+ 10)
  (defconstant +authtok-prompt+ 11)
  (defconstant +oldauthtok-prompt+ 12)

;;; OpenPAM conversation

  (defconstant +prompt-echo-off+ 1)
  (defconstant +prompt-echo-on+ 2)
  (defconstant +error-msg+ 3)
  (defconstant +text-info+ 4)
  (defconstant +max-num-msg+ 32)
  (defconstant +max-msg-size+ 512)
  (defconstant +max-resp-size+ 512)
  )

(defun item-foreign-type (item-type)
  "Return the foreign type corresponding to the given PAM item type."
  (if (member item-type (list +conv+ +authtok+ +oldauthtok+ #+linux +fail-delay+ #+linux +xauthdata+ #-linux +repository+))
      :pointer
      :string))

;;; PAM Handle Class Wrapper

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defclass handle-class (c2mop:standard-class) ())

  (defmethod c2mop:validate-superclass ((c1 handle-class) (c2 standard-class)) t)

  (defclass handle-slot (c2mop:standard-effective-slot-definition)
    ((item-type :initarg :item-type
                :initform nil
                :reader handle-slot-item-type)))

  (defclass handle-direct-slot (c2mop:standard-direct-slot-definition)
    ((item-type :initarg :item-type
                :initform nil)))

  (defmethod c2mop:direct-slot-definition-class ((class handle-class) &rest initargs)
    (declare (ignore initargs))
    (find-class 'handle-direct-slot))

  (defmethod c2mop:effective-slot-definition-class ((class handle-class) &rest initargs)
    (declare (ignore initargs))
    (find-class 'handle-slot))

  (defmethod c2mop:compute-effective-slot-definition :around ((class handle-class) name dslotds)
    (let ((slotd (call-next-method)))
      (when (slot-value (car dslotds) 'item-type)
        (setf (slot-value slotd 'item-type)
              (eval (slot-value (car dslotds) 'item-type))))
      slotd))

  (defmethod c2mop:slot-value-using-class ((class handle-class) obj slotd)
    (if (handle-slot-item-type slotd)
        (handle-get-item obj (handle-slot-item-type slotd))
        (call-next-method)))

  (defmethod (setf c2mop:slot-value-using-class) (value (class handle-class) obj slotd)
    (if (handle-slot-item-type slotd)
        (handle-set-item obj (handle-slot-item-type slotd) value)
        (call-next-method)))

  (defclass handle ()
    ((object :initarg :object
             :accessor handle-object)
     (status :initform +success+
             :accessor handle-status)
     (service :initarg :service
              :initform nil
              :accessor handle-service
              :item-type +service+)
     (user :initarg :user
           :initform nil
           :accessor handle-user
           :item-type +user+)
     (tty :initarg :tty
          :initform nil
          :accessor handle-tty
          :item-type +tty+)
     (rhost :initarg :rhost
            :initform nil
            :accessor handle-rhost
            :item-type +rhost+)
     (conv :initarg :conv
           :initform nil
           :accessor handle-conv
           :item-type +conv+)
     (authtok :initarg :authtok
              :initform nil
              :accessor handle-authtok
              :item-type +authtok+)
     (oldauthtok :initarg :oldauthtok
                 :initform nil
                 :accessor handle-oldauthtok
                 :item-type +oldauthtok+)
     (ruser :initarg :ruser
            :initform nil
            :accessor handle-ruser
            :item-type +ruser+)
     (user-prompt :initarg :user-prompt
                  :initform nil
                  :accessor handle-user-prompt
                  :item-type +user-prompt+)
     #+linux
     (fail-delay :initarg :fail-delay
                 :initform nil
                 :accessor handle-fail-delay
                 :item-type +fail-delay+)
     #+linux
     (xdisplay :initarg :xdisplay
               :initform nil
               :accessor handle-xdisplay
               :item-type +xdisplay+)
     #+linux
     (xauthdata :initarg :xauthdata
                :initform nil
                :accessor handle-xauthdata
                :item-type +xauthdata+)
     #+linux
     (authtok-type :initarg :authtok-type
                   :initform nil
                   :accessor handle-authtok-type
                   :item-type +authtok-type+)
     #-linux
     (repository :initarg :repository
                 :initform nil
                 :accessor handle-repository
                 :item-type +repository+)
     #-linux
     (authtok-prompt :initarg :authtok-prompt
                     :initform nil
                     :accessor handle-authtok-prompt
                     :item-type +authtok-prompt+)
     #-linux
     (oldauthtok-prompt :initarg :oldauthtok-prompt
                        :initform nil
                        :accessor handle-oldauthtok-prompt
                        :item-type +oldauthtok-prompt+))
    (:metaclass handle-class)))

;;; Helper Functions for Item Access

(defun handle-get-item (handle type)
  (let ((pamh (handle-object handle)))
    (with-foreign-object (ret :pointer)
      (let ((result (pam/raw:get-item pamh type ret)))
        (setf (handle-status handle) result)
        (if (eql result +success+)
            (mem-ref ret (item-foreign-type type))
            (error 'pam-error :pamh pamh
                              :func "pam_get_item"
                              :args (list pamh type ret)
                              :errno result))))))

(defun handle-set-item (handle type item)
  (let ((pamh (handle-object handle)))
    (if (stringp item)
        (with-foreign-string (item-ptr item)
          (let ((result (pam/raw:set-item pamh type item-ptr)))
            (setf (handle-status handle) result)
            (if (eql result +success+)
                item
                (error 'pam-error :pamh pamh
                                  :func "pam_set_item"
                                  :args (list pamh type item-ptr)
                                  :errno result))))
        (let ((result (pam/raw:set-item pamh type item)))
          (setf (handle-status handle) result)
          (if (eql result +success+)
              item
              (error 'pam-error :pamh pamh
                                :func "pam_set_item"
                                :args (list pamh type item)
                                :errno result))))))

;;; Initialization and Real pam_start

(defmethod initialize-instance ((self handle)
                                &key
                                  object
                                  service
                                  user
                                  tty
                                  rhost
                                  conv
                                  authtok
                                  oldauthtok
                                  ruser
                                  user-prompt
                                  #+linux
                                  fail-delay
                                  #+linux
                                  xdisplay
                                  #+linux
                                  xauthdata
                                  #+linux
                                  authtok-type
                                  #-linux
                                  repository
                                  #-linux
                                  authtok-prompt
                                  #-linux
                                  oldauthtok-prompt)
  (cond ((pointerp object)
         (setf (handle-object self) object))
        (object (error "PAM handle object must be a pointer."))
        (t (with-foreign-object (ret :pointer)
             (let ((result (pam/raw:start service user conv ret)))
               (if (eql result +success+)
                   (setf (handle-object self) (mem-ref ret :pointer)
                         service nil
                         user nil
                         conv nil)
                   (error 'pam-error :pamh ret
                                     :func "pam_start"
                                     :args (list service user conv ret)
                                     :errno result))))))
  (when service
    (setf (slot-value self 'service) service))
  (when user
    (setf (slot-value self 'user) user))
  (when tty
    (setf (slot-value self 'tty) tty))
  (when rhost
    (setf (slot-value self 'rhost) rhost))
  (when conv
    (setf (slot-value self 'conv) conv))
  (when authtok
    (setf (slot-value self 'authtok) authtok))
  (when oldauthtok
    (setf (slot-value self 'oldauthtok) oldauthtok))
  (when ruser
    (setf (slot-value self 'ruser) ruser))
  (when user-prompt
    (setf (slot-value self 'user-prompt) user-prompt))
  #+linux
  (when fail-delay
    (setf (slot-value self 'fail-delay) fail-delay))
  #+linux
  (when xdisplay
    (setf (slot-value self 'xdisplay) xdisplay))
  #+linux
  (when xauthdata
    (setf (slot-value self 'xauthdata) xauthdata))
  #+linux
  (when authtok-type
    (setf (slot-value self 'authtok-type) authtok-type))
  #-linux
  (when repository
    (setf (slot-value self 'repository) repository))
  #-linux
  (when authtok-prompt
    (setf (slot-value self 'authtok-prompt) authtok-prompt))
  #-linux
  (when oldauthtok-prompt
    (setf (slot-value self 'oldauthtok-prompt) oldauthtok-prompt)))

;;; PAM API Functions

(defun start (service user conv)
  "Initialize and return a PAM handle for the given service, user, and
conversation function.

Wrapper for (make-instance 'pam:handle), which in turn wraps pam_start."
  (make-instance 'handle :service service :user user :conv conv))

(defun end (handle)
  "Terminate the PAM handle.

Wrapper for pam_end"
  (let ((result (pam/raw:end (handle-object handle)
                             (handle-status handle))))
    (if (eql result +success+) t
        (error 'pam-error :pamh (handle-object handle)
                          :func "pam_end"
                          :args (list (handle-object handle)
                                      (handle-status handle))
                          :errno result))))

(defun acct-mgmt (handle &key silent disallow-null-authtok &aux (flags 0))
  "Wrapper for pam_acct_mgmt

Raising PAM-ERROR on failure, returning t on success."
  (when silent (setq flags (logior flags +silent+)))
  (when disallow-null-authtok (setq flags (logior flags +disallow-null-authtok+)))
  (let ((result (pam/raw:acct-mgmt (handle-object handle) flags)))
    (setf (handle-status handle) result)
    (if (eql result +success+) t
        (error 'pam-error :pamh (handle-object handle)
                          :func "pam_acct_mgmt"
                          :args (list (handle-object handle) flags)
                          :errno result))))

(defun authenticate (handle &key silent disallow-null-authtok &aux (flags 0))
  "Wrapper for pam_authenticate

Raising PAM-ERROR on failure, returning t on success."
  (when silent (setq flags (logior flags +silent+)))
  (when disallow-null-authtok (setq flags (logior flags +disallow-null-authtok+)))
  (let ((result (pam/raw:authenticate (handle-object handle) flags)))
    (setf (handle-status handle) result)
    (if (eql result +success+) t
        (error 'pam-error :pamh (handle-object handle)
                          :func "pam_authenticate"
                          :args (list (handle-object handle) flags)
                          :errno result))))

(defun setcred (handle &key silent establish-cred delete-cred reinitialize-cred refresh-cred &aux (flags 0))
  "Wrapper for pam_setcred

Raising PAM-ERROR on failure, returning t on success."
  (when silent (setq flags (logior flags +silent+)))
  (when establish-cred (setq flags (logior flags +establish-cred+)))
  (when delete-cred (setq flags (logior flags +delete-cred+)))
  (when reinitialize-cred (setq flags (logior flags +reinitialize-cred+)))
  (when refresh-cred (setq flags (logior flags +refresh-cred+)))
  (let ((result (pam/raw:setcred (handle-object handle) flags)))
    (setf (handle-status handle) result)
    (if (eql result +success+) t
        (error 'pam-error :pamh (handle-object handle)
                          :func "pam_setcred"
                          :args (list (handle-object handle) flags)
                          :errno result))))

(defun chauthtok (handle &key silent change-expired-authtok &aux (flags 0))
  "Wrapper for pam_chauthtok

Raising PAM-ERROR on failure, returning t on success."
  (when silent (setq flags (logior flags +silent+)))
  (when change-expired-authtok (setq flags (logior flags +change-expired-authtok+)))
  (let ((result (pam/raw:chauthtok (handle-object handle) flags)))
    (setf (handle-status handle) result)
    (if (eql result +success+) t
        (error 'pam-error :pamh (handle-object handle)
                          :func "pam_chauthtok"
                          :args (list (handle-object handle) flags)
                          :errno result))))

(defun open-session (handle &key silent &aux (flags 0))
  "Wrapper for pam_open_session

Raising PAM-ERROR on failure, returning t on success."
  (when silent (setq flags (logior flags +silent+)))
  (let ((result (pam/raw:open-session (handle-object handle) flags)))
    (setf (handle-status handle) result)
    (if (eql result +success+) t
        (error 'pam-error :pamh (handle-object handle)
                          :func "pam_open_session"
                          :args (list (handle-object handle) flags)
                          :errno result))))

(defun close-session (handle &key silent &aux (flags 0))
  "Wrapper for pam_close_session

Raising PAM-ERROR on failure, returning t on success."
  (when silent (setq flags (logior flags +silent+)))
  (let ((result (pam/raw:close-session (handle-object handle) flags)))
    (setf (handle-status handle) result)
    (if (eql result +success+) t
        (error 'pam-error :pamh (handle-object handle)
                          :func "pam_close_session"
                          :args (list (handle-object handle) flags)
                          :errno result))))

(defun getenv (handle name)
  "Wrapper for pam_getenv

Returning the value of the env var, or nil if it is not set."
  (pam/raw:getenv (handle-object handle) name))

(defun putenv (handle name value)
  "Wrapper for pam_putenv

Remove the env var if VALUE is nil."
  (pam/raw:putenv (handle-object handle)
                  (if value
                      (format nil "~A=~A" name value)
                      name)))

(defun getenvlist (handle)
  "Wrapper for pam_getenvlist

Returns an alist of env var (NAME . VALUE), or nil on failure (session
is not opened, etc.)"
  (let ((lst (pam/raw:getenvlist (handle-object handle))))
    (unless (null-pointer-p lst)
      (unwind-protect
           (loop for i from 0
                 until (null-pointer-p (mem-aref lst :pointer i))
                 collect (destructuring-bind (key val)
                             (split-sequence:split-sequence #\= (mem-aref lst :string i))
                           (cons key val))
                 do (foreign-free (mem-aref lst :pointer i)))
        (foreign-free lst)))))

;;; Demo

#+nil
(progn
  ;; 1. Define the conversation callback.
  ;;    PAM calls this when it needs info (e.g. a password).
  ;;    ptr-to-secret holds a foreign pointer to the password string.
  (defcallback converse :int ((num-msg :int)
                              (msg :pointer)
                              (ptr-to-resp-arr :pointer)
                              (ptr-to-secret :pointer))
    (let ((resp-arr (foreign-alloc '(:struct response) :count num-msg)))
      (loop for i from 0 below num-msg
            for msg-struct = (mem-aref msg :pointer i)
            for resp-struct = (mem-aref resp-arr '(:struct response) i)
            do (with-foreign-slots ((msg-style msg) msg-struct (:struct message))
                 (with-foreign-slots ((resp resp-retcode) resp-struct (:struct response))
                   (case msg-style
                     (+prompt-echo-off+
                      (setf resp (mem-ref ptr-to-secret :string)
                            resp-retcode 0))
                     (+error-msg+
                      (format t "Converse Error message: ~A~%" (mem-ref msg :string))
                      (setf resp (null-pointer)
                            resp-retcode 0))
                     (+text-info+
                      (format t "Converse Info message: ~A~%" (mem-ref msg :string))
                      (setf resp (null-pointer)
                            resp-retcode 0))
                     (t
                      (format t "PAM_PROMPT_ECHO_ON received during converse, ~
                                 check if username is set correctly.~%")
                      (dotimes (j i)
                        (with-foreign-slots ((resp) (mem-aref resp '(:struct response) i)
                                                    (:struct response))
                          (foreign-free resp)
                          (setf resp (null-pointer))))
                      (foreign-free resp-arr)
                      (return +conv-err+)))))
            finally (progn (setf (mem-ref ptr-to-resp-arr :pointer) resp-arr)
                           (return +success+)))))

  ;; 2. Set up the pam_conv struct, pointing appdata_ptr at our secret holder.
  (setf ptr-to-secret (foreign-alloc :pointer)
        conv-struct (foreign-alloc '(:struct conv)))
  (with-foreign-slots ((conv appdata-ptr) conv-struct (:struct conv))
    (setf conv (callback converse)
          appdata-ptr ptr-to-secret))

  ;; 3. Start a PAM session.
  (setf handle (pam:start "passwd" "april" conv-struct))

  ;; 4. Store the password and authenticate.
  (setf (mem-ref ptr-to-secret :pointer) (foreign-string-alloc "hunter2"))
  (unwind-protect
       (handler-case
           (pam:authenticate handle)
         (pam:pam-error (e)
           (if (eql (pam:pam-error-errno e) pam:+auth-err+)
               (error "Password incorrect!")
               (error e))))
    ;; 5. Clean up.
    (foreign-string-free (mem-ref ptr-to-secret :pointer))
    (setf (mem-ref ptr-to-secret :pointer) (null-pointer))
    (pam:end handle)
    (foreign-free ptr-to-secret)
    (foreign-free conv-struct)))
