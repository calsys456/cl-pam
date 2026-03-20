(asdf:defsystem cl-pam
  :author "The Calendrical System"
  :license "0BSD"
  :description "Pure Lisp PAM implementation."
  :depends-on (cffi closer-mop split-sequence)
  :components ((:file "raw")
               (:file "pam")))
