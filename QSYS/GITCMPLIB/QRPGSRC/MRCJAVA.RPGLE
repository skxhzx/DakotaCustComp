     h DftActgrp(*NO) ActGrp(*Caller)

     d returnString    s            512A
     D StringClass     c                   'java.lang.String'
     D rtnString       s               o   class(*java : stringClass)

     D Exc_Cmd         PR                  extpgm('QCMDEXC')
     D  command                     200A   const
     D  length                       15P 5 const

      * Prototype for SimpleJava Main() function
     d PassString      PR              o   STATIC EXTPROC(*JAVA:
     d                                     'mrc.MRCHttpUrlConnection':
     d                                     'mrcReports')
     d                                     CLASS(*JAVA: StringClass)
     d String                          o   CLASS(*JAVA: StringClass)
     d                                      dim(12)
     d                                      Const

      * Prototype for Java String Object
     d crtString       PR              o   EXTPROC(*JAVA:
     d                                             StringClass :
     d                                             *CONSTRUCTOR)
     d RPGBytes                   65535A   Const Varying

      * Prototype for Java String's getBytes method
     d cvtToBytes      PR           512A   EXTPROC(*JAVA:
     d                                             'java.lang.String':
     d                                             'getBytes')
     d                                     Varying

      * Input/Output object
     d args            s               o   Class(*JAVA: StringClass)
     d                                     dim(12)

      *----------------------------------------------------------------
      * Prototype for MRCJAVA
      *----------------------------------------------------------------
     D mrcJava         PR                  EXTPGM('MRCJAVA')
     D  outFormat                     2
     D  reportName                  100
     d  url                        3000
     d  emailyn                       1
     d  emailTo                    1000
     d  ipaddr                       15
     d  ipport                        5
     D  subject                     100A
     D  emailBody                  5000A
     D  filePath                    100A
     d  dbsrc                        30A

     D mrcJava         PI
     D  outFormat                     2
     D  reportName                  100
     d  url                        3000
     d  emailyn                       1
     d  emailTo                    1000
     d  ipaddr                       15
     d  ipport                        5
     D  subject                     100A
     D  emailBody                  5000A
     D  filePath                    100A
     d  dbsrc                        30A

      /free

           Exc_Cmd('CD (''/PIRJAVA'')':200);

           args(1) = crtString(%trim(outFormat));   //PDF, EXCEL, HTML
           args(2) = crtString(%trim(reportName));  //Report Name
           args(3) = crtString(%trim(url));         //Report URL
           args(4) = crtString(%trim(emailyn));     //Email Y/N
           args(5) = crtString(%trim(emailTo));     //email address
           args(6) = crtString(%trim('N'));         //debug Y/N
           args(7) = crtString(%trim(ipAddr));      //IP Address
           args(8) = crtString(%trim(ipport));      //Port Number
           args(9) = crtString(%trim(subject));     //Email Subject
           args(10) = crtString(%trim(emailbody));  //Email Body
           args(11) = crtString(%trim(filePath));   //File Path
           args(12) = crtString(%trim(dbSrc));      //DB Source

           //PassString(args);
           returnString = cvtToBytes(PassString(args));

           *inlr = *on;
           return;

       /end-free
