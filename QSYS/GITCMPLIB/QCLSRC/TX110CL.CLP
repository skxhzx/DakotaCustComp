/*-------------------------------------------------------------------*/
/*  Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved      */
/*  BFC Software, Inc.                                               */
/*  245 W. Roosevelt Rd.  Bldg 8, Suite 51                           */
/*  West Chicago, IL  60185                                          */
/*  (630) 562-0375                                                   */
/*-------------------------------------------------------------------*/
/*                                                                   */
/*  TX110CL   TX Truck Builder FTP Status - Display                  */
/*  19 July 2006                                                     */
/*  Robin Clark       Copied from FP110CL                            */
/*                                                                   */
/*-------------------------------------------------------------------*/

 TX110CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MEMBER) TYPE(*CHAR) LEN(10)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Define file to be used for display         */
/*      - Share it with everyone that follows. */
/*      - Open it to allow Input and Output.   */

/*  Define work file to be used for display options.  */
/*    - Get unique member to use.                     */
/*    - Override file to use unique member.           */

             IF (&MEMBER = ' ') DO
                CALL       PGM(GETUNQMEM) PARM(*REUSE WORKOPT &MEMBER)
                ENDDO

             OVRDBF     FILE(WORKOPT) MBR(&MEMBER) SHARE(*YES)

/*  On with the show ... */

             CALL       PGM(TX110)

DONE:

/*  Clean up before leaving */

             DLTOVR     FILE(WORKOPT)
             MONMSG     MSGID(CPF9841) /* Ignore not deleted. */
             RCLRSC     LVL(*CALLER)
             RMVM       FILE(WORKOPT) MBR(&MEMBER)
             MONMSG     MSGID(CPF320A CPF320B CPF3203 CPF3220 +
                          CPF3273 CPF7301 CPF7310 CPF0001)

             ENDPGM
