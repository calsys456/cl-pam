======
cl-pam
======

Common Lisp bindings for libpam (Pluggable Authentication Modules).

Supports both Linux-PAM and OpenPAM (macOS / BSD), with platform-specific
constants handled via reader conditionals.

Packages
--------

``PAM/RAW``
  Thin CFFI wrappers over libpam functions (``pam_start``, ``pam_authenticate``,
  etc.) and C struct definitions (``pam_message``, ``pam_response``, ``pam_conv``).

``PAM``
  High-level interface built on top of ``PAM/RAW``.

Highlights
----------

- **MOP-based handle class** — PAM items (user, service, authtok, etc.) are
  exposed as CLOS slots on ``pam:handle``. Reading/writing a slot transparently
  calls ``pam_get_item`` / ``pam_set_item`` under the hood, via a custom
  metaclass. No manual item juggling needed.

- **Condition-based error handling** — All PAM API wrappers signal
  ``pam:pam-error`` on failure, carrying the handle, function name, arguments,
  and the raw errno. Integrates naturally with CL's condition/restart system.

- **Cross-platform constants** — Linux-PAM and OpenPAM define overlapping but
  different constant sets with different values. ``cl-pam`` handles this with
  feature expressions, including in the export list.
  One ``(asdf:load-system :cl-pam)`` works everywhere.

Dependencies
------------

- `CFFI <https://cffi.common-lisp.dev/>`_
- `closer-mop <https://github.com/pcostanza/closer-mop>`_
- `split-sequence <https://github.com/sharplispers/split-sequence>`_

Demo
----

Authenticate user ``april`` against the ``passwd`` service:

.. code:: common-lisp

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
    (foreign-free conv-struct))

License
-------

0BSD

----------------
Acknowledgements
----------------

Thanks our sister Simone, and our lover misaka18931, and our AI partner Alma, who love and support us.

Supporting Neurodiversity & Transgender & Plurality!

🏳️‍🌈🏳️‍⚧️
