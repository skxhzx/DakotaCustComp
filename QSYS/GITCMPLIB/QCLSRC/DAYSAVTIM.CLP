/*-------------------------------------------------------------------*/
/*                                                                   */
/*  DAYSAVTIM  Perform automatic Daylight Savings Time adjustments.  */
/*  18 March 2004                                                    */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    03/18/04  DAS  4.17                                            */
/*      - Created.                                                   */
/*                                                                   */
/*-------------------------------------------------------------------*/

/*-------------------------------------------------------------------*/
/*  Taken from: Midrange Computing, December 1997, page 13.          */
/*               from David Hummell, mod of program by Lori Nesje)   */
/*              Modified by Lori Nesje                               */
/*              Modified by Neil Palmer, DPS Canada Ltd.             */
/*-------------------------------------------------------------------*/

/*-------------------------------------------------------------------*/
/* Compile Notes:                                                    */
/*                                                                   */
/*  Program should be compiled with USRPRF(*OWNER), and              */
/*  the owner should have authority to CHGSYSVAL QHOUR               */
/*  - OR -                                                           */
/*  the Job Schedule entry should name a USER that has               */
/*  authority to CHGSYSVAL QHOUR.                                    */
/*                                                                   */
/*-------------------------------------------------------------------*/

/*-------------------------------------------------------------------*/
/* Add to system job scheduler as follows (substitute valid USER):  */
/*                                                                   */
/*        ADDJOBSCDE JOB(AUTO_DST) CMD(CALL PGM(QGPL/DAYSAVTIM)) +   */
/*                   FRQ(*MONTHLY) SCDDATE(*NONE) SCDDAY(*SUN) +     */
/*                   SCDTIME(020000) RELDAYMON(1 *LAST) +            */
/*                   JOBQ(QSYSNOMAX) USER(????) TEXT('Daylight +     */
/*                   Savings Time adjustment program')               */
/*                                                                   */
/*-------------------------------------------------------------------*/

DAYSAVTIM:   PGM

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&MONTH)      TYPE(*CHAR) LEN(2)
             DCL        VAR(&DAY)        TYPE(*CHAR) LEN(2)
             DCL        VAR(&DOW)        TYPE(*CHAR) LEN(4)
             DCL        VAR(&HOUR)       TYPE(*CHAR) LEN(2)
             DCL        VAR(&HOUR#)      TYPE(*DEC)  LEN(2 0)
             DCL        VAR(&UTCOFFSET)  TYPE(*CHAR) LEN(5)
             DCL        VAR(&UTCOFFSET#) TYPE(*DEC)  LEN(5 0)
             DCL        VAR(&MSG)        TYPE(*CHAR) LEN(128)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Get current system values  */

             RTVSYSVAL  SYSVAL(QMONTH)      RTNVAR(&MONTH)
             RTVSYSVAL  SYSVAL(QDAY)        RTNVAR(&DAY)
             RTVSYSVAL  SYSVAL(QDAYOFWEEK)  RTNVAR(&DOW)
             RTVSYSVAL  SYSVAL(QHOUR)       RTNVAR(&HOUR)
             RTVSYSVAL  SYSVAL(QUTCOFFSET)  RTNVAR(&UTCOFFSET)

             CHGVAR     VAR(&HOUR#) VALUE(&HOUR)
             CHGVAR     VAR(&UTCOFFSET#) VALUE(&UTCOFFSET)

/*  If this is not Sunday, then the system was down on Sunday. */
/*  Time may have been set manually, so don't change anything. */
/*  Send message to system operator to check the time.         */

             IF         (&DOW *NE '*SUN') THEN(DO)
             SNDPGMMSG  MSG('The job to automatically change the +
                          time for Daylight Savings did not run on +
                          Sunday, so the program did not adjust the +
                          time. Therefore, please verify the system +
                          time is set correctly.') TOMSGQ(*SYSOPR)
             GOTO       CMDLBL(END)
             ENDDO

/*  See if we are out of the acceptable day range for this program */
/*  to run. If we are, send a message to the system operator to    */
/*  check the time.                                                */

             IF ((&MONTH = '04' *AND &DAY > '15') *OR +
                 (&MONTH = '10' *AND &DAY < '15')) THEN(DO)
             SNDPGMMSG  MSG('The job to automatically change the +
                          time for Daylight Savings did not run on +
                          an acceptable day of the month, so the +
                          program did not adjust the time. +
                          Therefore, please verify the system time +
                          is set correctly.') TOMSGQ(*SYSOPR)
             GOTO       CMDLBL(END)
             ENDDO

/*  Send message of current hour and offsett  */

             CHGVAR     VAR(&MSG) VALUE('The current hour and  +
                          offset are ' +
                          *BCAT &HOUR *BCAT 'and' *BCAT &UTCOFFSET)
             SNDPGMMSG  MSG(&MSG) TOMSGQ(*SYSOPR)

/*  See if we we need to spring ahead ...  */

             IF         (&MONTH = '04') THEN(DO)
               CHGVAR     VAR(&HOUR#) VALUE(&HOUR# +1)
               CHGVAR     VAR(&UTCOFFSET#) VALUE(&UTCOFFSET# +100)
             ENDDO

/*  ... or fall back.  */

             IF         (&MONTH = '10') THEN(DO)
               CHGVAR     VAR(&HOUR#) VALUE(&HOUR# -1)
               CHGVAR     VAR(&UTCOFFSET#) VALUE(&UTCOFFSET# -100)
             ENDDO

/*  Update the system hour  */

             CHGVAR     VAR(&HOUR) VALUE(&HOUR#)
             CHGSYSVAL  SYSVAL(QHOUR) VALUE(&HOUR)

/*  Update the system UTC offset  */

             IF (&UTCOFFSET# > 2400) +
                CHGVAR &UTCOFFSET# (&UTCOFFSET# - 2400)
             IF (&UTCOFFSET# < -2400) +
                CHGVAR &UTCOFFSET# (&UTCOFFSET# + 2400)
             IF ((&UTCOFFSET# < -45) & (&UTCOFFSET# > -100)) +
                CHGVAR &UTCOFFSET# (&UTCOFFSET# + 40)
             IF ((&UTCOFFSET# > 45) & (&UTCOFFSET# < 100)) +
                CHGVAR &UTCOFFSET# (&UTCOFFSET# - 40)
             CHGVAR     VAR(&UTCOFFSET) VALUE(&UTCOFFSET#)
             IF (&UTCOFFSET# >= 0) THEN(CHGVAR +
                 &UTCOFFSET ('+' *CAT %SST(&UTCOFFSET 2 4)))
             CHGSYSVAL  SYSVAL(QUTCOFFSET) VALUE(&UTCOFFSET)

/*  Send message saying the time has been adjusted  */

             CHGVAR     VAR(&MSG) VALUE('The new hour and  +
                          offset are ' +
                          *BCAT &HOUR *BCAT 'and' *BCAT &UTCOFFSET)
             SNDPGMMSG  MSG(&MSG) TOMSGQ(*SYSOPR)

             SNDPGMMSG  MSG('The Hour and UTC offset have been +
                          automatically adjusted for Daylight +
                          Savings Time.') TOMSGQ(*SYSOPR)
 END:        ENDPGM
