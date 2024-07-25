/*------------------------------------------------------------------*/
/*  English Version (Spanish version is EPMSGDSP)                   */
/*  Any change made to these messages must also be made to Spanish  */
/*  For new messages, copy them into Spanish source, put a comment  */
/*  of TRANSLATE on the blank line above the CHGVAR &MSG line.      */
/*  Then contact the appropriate person to do the translation.      */
/*------------------------------------------------------------------*/
/*                                                                  */
/*  EPMSGD      Create PIRMSGF Message Descriptions EPpppnn         */
/*                 where ppp = Program number (ie 110)              */
/*                       nn  = Error message id (01-99)             */
/*              Receiving error messages                            */
/*                                                                  */
/*  15 February 1993                                                */
/*  Dave Sommerville                                                */
/*                                                                  */
/*  Revisions:                                                      */
/*  06/04/98  HNK  4.09                                             */
/*    - TE11219 message added.                                      */
/*  11/05/03  RH   4.17a                                            */
/*    - TE11221, TE11222 message added                              */
/*                                                                  */
/*------------------------------------------------------------------*/

             PGM        PARM(&OPT)

             DCL        VAR(&MSGID) TYPE(*CHAR) LEN(7)
             DCL        VAR(&MSGF) TYPE(*CHAR) LEN(10) VALUE(PIRMSGF)
             DCL        VAR(&MSGFLIB) TYPE(*CHAR) LEN(10) +
                        VALUE(*LIBL)
             DCL        VAR(&OPT) TYPE(*CHAR) LEN(7)

/*  ER21001 Start date must be a sunday. */

             CHGVAR     VAR(&MSGID) VALUE('ER21001')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Starting date must be a sunday.') +
                          SECLVL('Cause . . . . . :   The date &1 +
                          is a &2 date. &N Recovery  . . . :   +
                          Enter sunday''s date and try your request +
                          again.') SEV(30) FMT((*DEC 6) (*CHAR 10))
             ENDDO

/*  ER21002 Record selection in progress. */

             CHGVAR     VAR(&MSGID) VALUE('ER21002')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Records are being selected.  Please +
                          be patient.')
             ENDDO

/*  PD11201 Invalid type entered. */

             CHGVAR     VAR(&MSGID) VALUE('PD11201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Invalid type entered') SECLVL('Cause +
                          . . . . . :   Type must be a ''W'' or +
                          ''P'' or ''L''. &N Recovery  . . . :   +
                          Enter ''W'' for Workstation, ''P'' for +
                          Printer, or ''L'' for Label Printer.') +
                          SEV(30)
             ENDDO

/*  PD11202 Invalid section entered. */

             CHGVAR     VAR(&MSGID) VALUE('PD11202')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Invalid section entered') +
                          SECLVL('Cause . . . . . :   Section +
                          must be a ''F'' or ''P''. &N Recovery  . +
                          . . :   Enter ''F'' for fixed or ''P'' +
                          for PIR.') SEV(30)
             ENDDO

/*  SH11201 Hour must <or= 23.       */

             CHGVAR     VAR(&MSGID) VALUE('SH11201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Invalid hour entered') SECLVL('Cause +
                          . . . . . :   Hour entered is greater +
                          than 23. &N Recovery  . . . :   Enter a +
                          number less than or equal to 23 for +
                          hour.') SEV(30)
             ENDDO

/*  SH11202 Invalid minute entered. */

             CHGVAR     VAR(&MSGID) VALUE('SH11202')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Invalid minute entered.') +
                          SECLVL('Cause . . . . . :   Minute +
                          entered is greater than 59. &N Recovery  +
                          . . . :   Enter a number that is less +
                          than or equal to 59.') SEV(30)
             ENDDO

/*  TC11201 Invalid section entered. */

             CHGVAR     VAR(&MSGID) VALUE('TC11201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Must +
                          enter atleast one sub category') +
                          SECLVL('Cause . . . . . :   No sub +
                          category was entered. &N Recovery  . . . +
                          :   Enter atleast one valid sub catgory +
                          and try your request again.') SEV(30)
             ENDDO

/*  TD11201 Details does not exist for the task. */

             CHGVAR     VAR(&MSGID) VALUE('TD11201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Standards does not exist for the &1 +
                          task.') SECLVL('Cause . . . . . :   There +
                          are no standards for this task.  &N +
                          Recovery  . . . :   Select a task for +
                          which the standards already exists.') +
                          SEV(30) FMT((*CHAR 6))
             ENDDO

/*  TD11202 Standards cannot be entered for anon-std. task. */

             CHGVAR     VAR(&MSGID) VALUE('TD11202')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Standards cannot be defined for user +
                          defined task.') SECLVL('Cause . . . . . +
                          :   &1 is a user defined task and hence +
                          standards cannot be defined for this +
                          task.  &N Recovery  . . . :   Select a +
                          standard task and try your request +
                          again.') SEV(30) FMT((*CHAR 6))
             ENDDO

/*  TK11401 Cannot delete a standard task.  */

             CHGVAR     VAR(&MSGID) VALUE('TK11401')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Cannot delete a standard task.') +
                          SECLVL('Cause . . . . . :   &1 is a +
                          standard task.  Only non standard task +
                          can be deleted.  &N Recovery  . . . :   +
                          Select a non standard task and try your +
                          request again.') SEV(30) FMT((*CHAR 6))
             ENDDO

/*  TE11201 Task already started by another employee. */

             CHGVAR     VAR(&MSGID) VALUE('TE11201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('This +
                          transaction is already started by &1.') +
                          SECLVL('Cause . . . . . :   Transaction +
                          is already started by &1. Only pending +
                          tasks can be started.  &N Recovery  . . . +
                          :   Select a pending task, and try your +
                          request again.') SEV(30) FMT((*CHAR 30))
             ENDDO

/*  TE11202 Task is already closed. */

             CHGVAR     VAR(&MSGID) VALUE('TE11202')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('This +
                          transaction is already closed.') +
                          SECLVL('Cause . . . . . :   Transaction +
                          is already closed. Only pending tasks can +
                          be started.  &N Recovery  . . . :   +
                          Select a pending task, and try your +
                          request again.') SEV(30)
             ENDDO

/*  TE11203 Hour must <or= 12.       */

             CHGVAR     VAR(&MSGID) VALUE('TE11203')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Invalid hour entered') SECLVL('Cause +
                          . . . . . :   Hour entered is greater +
                          than 12. &N Recovery  . . . :   Enter a +
                          number less than or equal to 12 for +
                          hour.') SEV(30)
             ENDDO

/*  TE11204 Invalid minute entered. */

             CHGVAR     VAR(&MSGID) VALUE('TE11204')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Invalid minute entered.') +
                          SECLVL('Cause . . . . . :   Minute +
                          entered is greater than 59. &N Recovery  +
                          . . . :   Enter a number that is less +
                          than or equal to 59.') SEV(30)
             ENDDO

/*  TE11205 Standard task cannot be added. */

             CHGVAR     VAR(&MSGID) VALUE('TE11205')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Standard task cannot be added.') +
                          SECLVL('Cause . . . . . :   &1 is a +
                          standard task.  Only non-standard(manual) +
                          task can be entered. &N Recovery  . . . +
                          :   Enter a non-standard task and try +
                          your request again.') SEV(30) FMT((*CHAR 6))
             ENDDO

/*  TE11206 Task is already ended. */

             CHGVAR     VAR(&MSGID) VALUE('TE11206')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('This +
                          transaction is already ended.') +
                          SECLVL('Cause . . . . . :   Transaction +
                          is already ended. Only pending tasks can +
                          be started.  &N Recovery  . . . :   +
                          Select a pending task, and try your +
                          request again.') SEV(30)
             ENDDO

/*  TE11207 Task is interrupted. */

             CHGVAR     VAR(&MSGID) VALUE('TE11207')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('This +
                          transaction is interrupted.') +
                          SECLVL('Cause . . . . . :   Transaction +
                          is interrupted. Only pending tasks can be +
                          started.  &N Recovery  . . . :   Select a +
                          pending task, and try your request +
                          again.') SEV(30)
             ENDDO

/*  TE11208 Task is cancelled. */

             CHGVAR     VAR(&MSGID) VALUE('TE11208')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('This +
                          transaction is cancelled.') SECLVL('Cause +
                          . . . . . :   Transaction is cancelled. +
                          Only pending tasks can be started.  &N +
                          Recovery  . . . :   Select a pending +
                          task, and try your request again.') SEV(30)
             ENDDO

/*  TE11209  Start date must be < or = to the end date. */

             CHGVAR     VAR(&MSGID) VALUE('TE11209')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Start date must be less than or +
                          equal to the end date.') SECLVL('Cause . +
                          . . . . :   You have entered a start date +
                          (&2) that is greater than the end date +
                          (&5). &N Recovery  . . . :   Enter a new +
                          date that is less than or equal to the +
                          end date.') SEV(30) FMT((*CHAR 6) (*CHAR +
                          8) (*CHAR 8) (*CHAR 8) (*CHAR 8))
             ENDDO

/*  TE11210  Time lapse cannot be more than one day. */

             CHGVAR     VAR(&MSGID) VALUE('TE11210')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Time +
                          lapse cannot be more than one day.') +
                          SECLVL('Cause . . . . . :   You have +
                          entered an end date (&5) that is more +
                          than one day from the start date (&2). &N +
                          Recovery  . . . :   Enter an end date +
                          that is equal to the start date or is the +
                          day after the start date.') SEV(30) +
                          FMT((*CHAR 6) (*CHAR 8) (*CHAR 8) (*CHAR +
                          8) (*CHAR 8))
             ENDDO

/*  TE11211  If the dates are different, than end time must */
/*           be <= the start time.                          */

             CHGVAR     VAR(&MSGID) VALUE('TE11211')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('End +
                          time greater than the start time.') +
                          SECLVL('Cause . . . . . :   End time (&4) +
                          cannot be greater than the start time +
                          (&3), when the start (&2) and end dates +
                          (&5) are different. &N Recovery  . . . +
                          :   Enter end time that is less than or +
                          equal to the start time, and try your +
                          request again.') SEV(30) FMT((*CHAR 6) +
                          (*CHAR 8) (*CHAR 8) (*CHAR 8) (*CHAR 8))
             ENDDO

/*  TE11212  If the dates are same, than end time must */
/*           be > the start time.                      */

             CHGVAR     VAR(&MSGID) VALUE('TE11212')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('End +
                          time is either less than or equal to the +
                          start time.') SECLVL('Cause . . . . . :   +
                          End time (&4) cannot be less than or +
                          equal to the start time (&3), when the +
                          start (&2) and end dates (&5) are the +
                          same. &N Recovery  . . . :   Enter end +
                          time that is greater than the start time, +
                          and try your request again.') SEV(30) +
                          FMT((*CHAR 6) (*CHAR 8) (*CHAR 8) (*CHAR +
                          8) (*CHAR 8))
             ENDDO

/*  TE11213  End date cannot be > current date.        */

             CHGVAR     VAR(&MSGID) VALUE('TE11213')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('End +
                          date past the current date.') +
                          SECLVL('Cause . . . . . :   End date (&5) +
                          entered is past the current date. &N +
                          Recovery  . . . :   Enter an end date +
                          that is less than or equal to the current +
                          date.') SEV(30) FMT((*CHAR 6) (*CHAR 8) +
                          (*CHAR 8) (*CHAR 8) (*CHAR 8))
             ENDDO

/*  TE11214  End time cannot be > current time, if the */
/*           End date is = current date.               */

             CHGVAR     VAR(&MSGID) VALUE('TE11214')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('End +
                          time cannot be past the current time.') +
                          SECLVL('Cause . . . . . :   End time (&4) +
                          entered is past the current time. &N +
                          Recovery  . . . :   Enter an end time +
                          that is less than or equal to the current +
                          time.') SEV(30) FMT((*CHAR 6) (*CHAR 8) +
                          (*CHAR 8) (*CHAR 8) (*CHAR 8))
             ENDDO

/*  TE11215  Cannot change standard task.              */

             CHGVAR     VAR(&MSGID) VALUE('TE11215')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Cannot change standard task.') +
                          SECLVL('Cause . . . . . :   &1 is a +
                          standard task and hence cannot be +
                          changed. &N Recovery  . . . :   Select a +
                          non-standard (manual) task, and try your +
                          request again.') SEV(30) FMT((*CHAR 6))
             ENDDO

/*  TE11216 Invalid value entered for AM/PM. */

             CHGVAR     VAR(&MSGID) VALUE('TE11216')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Invalid value entered for AM/PM.') +
                          SECLVL('Cause . . . . . :   Value entered +
                          for AM/PM is other than ''A'' or ''P''.  +
                          &N Recovery  . . . :   Enter ''A'' for AM +
                          or ''P'' for PM and try your request +
                          again.') SEV(30)
             ENDDO

/*  TE11217 Overlapping time.                */

             CHGVAR     VAR(&MSGID) VALUE('TE11217')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Start and/or end time is +
                          overlapping.') SECLVL('Cause . . . . . +
                          :   The task you are trying to enter is +
                          overlapping &1 task, which was started on +
                          &2 at &3 hrs and ended at &4 hrs on &5.  +
                          &N Recovery  . . . :   Enter start and +
                          end time that is not overlapping any +
                          other task.') SEV(30) FMT((*CHAR 6) +
                          (*CHAR 8) (*CHAR 8) (*CHAR 8) (*CHAR 8))
             ENDDO

/*  TE11218 Overlapping an existing manual task.  */

             CHGVAR     VAR(&MSGID) VALUE('TE11218')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Start and end time is overlapping an +
                          existing manual task.') SECLVL('Cause . . +
                          . . . :   The task you are trying to +
                          enter is overlapping &1 task, which was +
                          started on &2 at &3 hrs and ended at &4 +
                          hrs on &5.  &N Recovery  . . . :   Enter +
                          start and end time that is not +
                          overlapping an existing manual task, and +
                          try your request again.') SEV(30) +
                          FMT((*CHAR 6) (*CHAR 8) (*CHAR 8) (*CHAR +
                          8) (*CHAR 8))
             ENDDO

/*  TE11219 Warning: Std task is active.  Do you really want to  */
/*          end that and start a manual task?                    */

             CHGVAR     VAR(&MSGID) VALUE('TE11219')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Warning: Standard task is active. +
                          Press help before proceeding.') +
                          SECLVL('Cause . . . . . :   A standard +
                          task is active at this time.  Starting a +
                          manual task here will end the standard +
                          task.  &N Recovery  . . . :   Enter the +
                          manual task by pressing the command key +
                          F6.') SEV(30)
             ENDDO

/*  TE11221 Multiple transactions exist for user. */

             CHGVAR     VAR(&MSGID) VALUE('TE11221')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Close +
                          previous multiple transactions.') SECLVL('Cause +
                          . . . . . :   Multiple transactions +
                          exist for user. Close before new transaction &N +
                          Recovery  . . . :   Close previous +
                          multiple transactions.') SEV(30)
             ENDDO

/*  TE11222 End Multiple transactions cancelled. */

             CHGVAR     VAR(&MSGID) VALUE('TE11222')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('End +
                          multiple transactions cancelled.') SECLVL('Cause +
                          . . . . . :   End multiple transactions +
                          program was cancelled by user. +
                          Recovery  . . . :   retry option to +
                          close multiple transactions.') SEV(30)
             ENDDO


/*  US11201 Invalid section entered. */

             CHGVAR     VAR(&MSGID) VALUE('US11201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Invalid section entered') +
                          SECLVL('Cause . . . . . :   Section +
                          must be a ''F'' or ''P''. &N Recovery  . +
                          . . :   Enter ''F'' for fixed or ''P'' +
                          for PIR.') SEV(30)
             ENDDO


             RETURN
             ENDPGM
