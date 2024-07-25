/*-------------------------------------------------------------------*/
/*   Copyright (C) 2003 BFC Software, Inc. - All Rights Reserved     */
/*   BFC Software, Inc.                                              */
/*   245 W. Roosevelt Rd.  Bldg 8, Suite 51                          */
/*   West Chicago, IL  60185                                         */
/*   (630) 562-0375                                                  */
/*-------------------------------------------------------------------*/
/*                                                                   */
/*  SL380ACL  CALL SL380CL WITH PARMS                                */
/*  01 February 2013                                                 */
/*  Roxanne Harrison                                                 */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*    01/29/20  MLB  7.40                                            */
/*      - ENH: Revised to add new parm for call to SL380CL. New      */
/*        selection option added to pgm.                             */
/*                                                                   */
/*-------------------------------------------------------------------*/

 SL380ACL:   PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(RCVEXCP)
             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(8)  VALUE(RE110)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MEMBER) TYPE(*CHAR) LEN(10)
             DCL        VAR(&RETURN) TYPE(*CHAR) LEN(8)
             DCL        VAR(&UNQKEY) TYPE(*CHAR) LEN(50)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/



/*  On with the show ... */

             CALL PGM(SL380CL) PARM('' '' '' '' '' '' '' '')

/*  Clean up before leaving */

             RCLRSC     LVL(*CALLER)

             ENDPGM
