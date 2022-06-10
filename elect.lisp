(defpackage #:elect
  (:use #:cl #:clog #:clog-gui)
  (:export start-app))

(in-package :elect)

(defun on-file-new (obj)
  (let* ((app (connection-data-item obj "app-data"))
	 (win (create-gui-window obj :title "New Window")))
    (declare (ignore app win))))

(defun on-help-about (obj)
  (let* ((about (create-gui-window obj
				   :title   "About"
				   :content "<div class='w3-black'>
                                         <center><img src='/img/clogwicon.png'></center>
	                                 <center>elect</center>
	                                 <center>elect</center></div>
			                 <div><p><center>A New App</center>
                                         <center>(c) 2022 - Some One</center></p></div>"
				   :hidden  t
				   :width   200
				   :height  200)))
    (window-center about)
    (setf (visiblep about) t)
    (set-on-window-can-size about (lambda (obj)
				    (declare (ignore obj))()))))

(defclass app-data ()
  ((data
    :accessor data)))

(defun on-new-window (body)
  (let ((app (make-instance 'app-data)))
    (setf (connection-data-item body "app-data") app)
    (setf (title (html-document body)) "New App")
    (clog-gui-initialize body)
    (add-class body "w3-teal")  
    (let* ((menu-bar    (create-gui-menu-bar body))
	   (icon-item   (create-gui-menu-icon menu-bar :on-click 'on-help-about))
	   (file-item   (create-gui-menu-drop-down menu-bar :content "File"))
	   (file-new    (create-gui-menu-item file-item :content "New Window" :on-click 'on-file-new))
	   (help-item   (create-gui-menu-drop-down menu-bar :content "Help"))
	   (help-about  (create-gui-menu-item help-item :content "About" :on-click 'on-help-about))
	   (full-screen (create-gui-menu-full-screen menu-bar)))
      (declare (ignore icon-item file-new help-about full-screen))))
  (clog:run body)
  (ceramic:quit)
  (clog:shutdown))

(defvar *window* nil)

(defun start-app (&key (port 8080))
  (ceramic:start)
  (initialize 'on-new-window
	      :port port
	      :static-root (ceramic:resource-directory 'www))
  (setf *window*
        (ceramic:make-window :url (format nil "http://127.0.0.1:~D/" port)))
  (ceramic:show *window*))

(ceramic:define-resources :elect ()
  (www #p"www/"))
  
(ceramic:define-entry-point :elect ()
  (start-app))
  
