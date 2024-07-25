      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *  TSTCHGUSER   Test changing current user
     *  05 February 2014
     *  Dave Sommerville
     *
     *  http://www.mysamplecode.com/2012/06/as400-switch-user-profile.html
     *----------------------------------------------------------------

     h dftactgrp(*NO) bnddir('QC2LE')

     d ProgStatus     sds
     d  Parms            *PARMS
     d  ProgName         *PROC
     d  ErrMsgID              40     46
     d  ErrMsg                91    169
     d  JobName              244    253
     d  UserId               254    263
     d  JobNumber            264    269

     d MyProgram       PR                  ExtPgm('MYPROGRAM')

     d GetUserProfile  PR                  ExtPgm('QSYGETPH')
     d  $userID                      10A   const
     d  $password                    10A   const
     d  $handle                      12A
     d  $errorCode                32766A   options(*varsize: *nopass)
     d  $length                      10I 0 const options(*nopass)
     d  $ccsid                       10I 0 const options(*nopass)

     d SetUserProfile  PR                  ExtPgm('QWTSETP')
     d  $handle                      12A   const
     d  $errorCode                32766A   options(*varsize: *nopass)

     d ErrorDS         DS
     d  $bytesPrv              1      4I 0 INZ(256)
     d  $bytesAvl              5      8I 0 INZ(0)
     d  $errMsgID              9     15
     d  $reserved             16     16
     d  $errMsgDta            17    256

     d  curHandle      s             12a
     d  newHandle      s             12a
     d  nUserId        s             10a   inz('VAI')
     d  nPassword      s             10a   inz('VAI9')
     d  length         s              4B 0 inz(10)
     d  ccsid          s              4B 0 inz(37)

      /free

        //Get handle on the current user profile, password not needed
        GetUserprofile(UserId: '*NOPWDCHK': curHandle: ErrorDS);
        if $bytesAvl > 0;
          //error
        else;
          //Get hanlde on the new user profile, password is needed here
          GetUserprofile(nUserId:
                         nPassword:
                         newHandle:
                         ErrorDS:
                        length:
                         ccsid);
          if $bytesAvl > 0;
            //error
          else;
            //Switch to new user profile
            SetUserProfile(newHandle: ErrorDs);
            if $bytesAvl > 0;
              //error
            else;
        //Change this to your own program call
              MyProgram();
              //Set the user profile back to the original user
              SetUserProfile(curHandle: ErrorDs);
              if $bytesAvl > 0;
                //error
             endif;
            endif;
          endif;
        endif;

        eval *inlr = *on;
        return;

      /end-free
