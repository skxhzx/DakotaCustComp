     h DftActgrp(*NO) ActGrp(*Caller)

     *----------------------------------------------------------------
     *   Copyright (C) 2003 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  BFCEMAIL  BFC Email Process
     *  02 November 2018
     *  Mike Rooker
     *
720  *    11/02/18  MR   7.20
     *      - Created
730  *    03/08/19  KDE  7.30
     *      - Fix:  Code to pass parms greater than 32 bytes using cl
     *
     *----------------------------------------------------------------
     * Notes
     *
     *
     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------
      /copy qcopysrc,c#stdvar
     *----------------------------------------------------------------
     * Variables
     *----------------------------------------------------------------
     D emailTo         s           1000a
     D subject         s            100a
     D body            s           5000a
     D ifsPath1        s            100A
     D ifsPath2        s            100A
     D ifsPath3        s            100A

     d returnString    s            512A
     D StringClass     c                   'java.lang.String'

     *----------------------------------------------------------------
     * Prototype for QCMDEXC
     *----------------------------------------------------------------
     D Exc_Cmd         PR                  extpgm('QCMDEXC')
     D  command                     200A   const
     D  length                       15P 5 const

     *----------------------------------------------------------------
     * Prototype for Java call function
     *----------------------------------------------------------------
     d PassString      PR              o   STATIC EXTPROC(*JAVA:
     d                                     'email.BFCEmail' :
     d                                     'sendMail')
     d                                     CLASS(*JAVA: StringClass)
     d String                          o   CLASS(*JAVA: StringClass)
     d                                      dim(6)
     d                                      Const

     *----------------------------------------------------------------
     * Prototype for Java String Object
     *----------------------------------------------------------------
     d crtString       PR              o   EXTPROC(*JAVA:
     d                                             StringClass :
     d                                             *CONSTRUCTOR)
     d RPGBytes                   65535A   Const Varying

     *----------------------------------------------------------------
     * Prototype for Java String's getBytes method
     *----------------------------------------------------------------
     d cvtToBytes      PR           512A   EXTPROC(*JAVA:
     d                                             'java.lang.String':
     d                                             'getBytes')
     d                                     Varying

     *----------------------------------------------------------------
     * Input/Output object
     *----------------------------------------------------------------
     d args            s               o   Class(*JAVA: StringClass)
     d                                     dim(6)

     c     *entry        plist
     c                   parm                    emailTo
     c                   parm                    subject
     c                   parm                    body
     c                   parm                    ifspath1
     c                   parm                    ifspath2
     c                   parm                    ifspath3

      /free

         //val emailTo = 'miker@bfcassociates.com';
         //val subject = 'Iseries test';
         //val body = 'this is an email test';
         //val ifspath1 = 'x';
         //val ifspath2 = 'x';
         //val ifspath3 = 'x';
         eval body = body + cr;

         //Change directory to PIRJAVA
           Exc_Cmd('CD (''/PIRJAVA'')':200);

         //Parameters for Java call
           args(1) = crtString(%trim(emailTo));  //Email To
           args(2) = crtString(%trim(subject));  //Subject
           args(3) = crtString(%trim(body));     //Body
           args(4) = crtString(%trim(ifsPath1));  //IFS Path 1
           args(5) = crtString(%trim(ifsPath2));  //IFS Path 2
           args(6) = crtString(%trim(ifsPath3));  //IFS Path 3

           //PassString(args);

         //Java call
           returnString = cvtToBytes(PassString(args));

           *inlr = *on;
           return;

       /end-free
