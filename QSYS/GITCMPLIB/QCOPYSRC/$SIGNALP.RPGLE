      *===================================================================
      *  Place in QCOPYSRC/$SIGNALP and include with /Copy statement:
      *    This copyfile member includes the following:
      *           - Procedures for Signal Interruption
      *===================================================================
      *
      * Revisions
      *
415bA *   01/17/14  KDE  6.60
      *     - Created
      *
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * Set up a signal handler to receive the SIGALRM signal
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P init_signals    B
     D init_signals    PI
     D act             DS                  likeds(sigaction_t)
      /free
        Qp0sEnableSignals();
        sigemptyset(act.sa_mask);
        sigaddset(act.sa_mask: SIGALRM);
        act.sa_handler   = %paddr(got_alarm);
        act.sa_flags     = 0;
        act.sa_sigaction = *NULL;
        sigaction(SIGALRM: act: *omit);
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * Whenever this program receives a SIGALRM signal, this
      * subprocedure will be called by the system
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P got_alarm       B                   EXPORT
     D got_alarm       PI
     D   signo                       10I 0 value
      /free
       // Do nothing. The API will return EINTR
       //  ("interrupted by signal") when the
       //  signal is received.
      /end-free
     P                 E


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * Connect with timeout
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P tconnect        B                   EXPORT
     D tconnect        PI            10I 0
     D   sock                        10I 0 value
     D   addr                          *   value
     D   size                        10I 0 value
     D   timeout                     10I 0 value
     D rc              s             10I 0
      /free
        alarm(timeout);
        rc = connect(sock: addr: size);
        alarm(0);
        return rc;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * Receive data with timeout
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P trecv           B                   EXPORT
     D trecv           PI            10I 0
     D   sock                        10I 0 value
     D   data                          *   value
     D   size                        10I 0 value
     D   timeout                     10I 0 value
     D rc              s             10I 0
      /free
         alarm(timeout);
         rc = recv(sock: data: size: 0);
         alarm(0);
         return rc;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * Send data with timeout
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P tsend           B                   EXPORT
     D tsend           PI            10I 0
     D   sock                        10I 0 value
     D   data                          *   value
     D   size                        10I 0 value
     D   timeout                     10I 0 value
     D rc              s             10I 0
      /free
         alarm(timeout);
         rc = send(sock: data: size: 0);
         alarm(0);
         return rc;
      /end-free
     P                 E
