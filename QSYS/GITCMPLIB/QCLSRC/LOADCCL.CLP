/*-------------------------------------------------------------------*/
/*                                                                   */
/*  LOADCCL:  Clear Loader Module files; LDRHDR, LDRDETL, LDRDTLBK   */
/*            NOTE: This program runs, automatically, every          */
/*                  day at 5:05 p.m. thru IBM job scheduler          */
/*                  under job name: CLRLOADR.                        */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*                                                                   */
/*  July 23, 2007                                                    */
/*  Jose Duque                                                       */
/*                                                                   */
/*  07/23/07  JGD                                                    */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*  01/02/15  RBD 6.50                                               */
/*    - Changed to use sql to delete records rather than using       */
/*      clrpfm to avoid crash if someone happens to be in            */
/*      Truckbuilder when this job runs.                             */
/*                                                                   */
/*  04/30/19  RBD 7.30                                               */
/*    - Also clear TTMERG.                                           */
/*                                                                   */
/*  07/21/23  RBD 7.70A                                              */
/*    - Copy TTMERG to TTMERGH history file before clearing TTMERG.  */
/*                                                                   */
/*-------------------------------------------------------------------*/

            PGM

             DCL        VAR(&STMT)       TYPE(*CHAR) LEN(1280)    /* (650 A) */

            /* Move any route left out in LDRHDR to LDRHHDR            */
             CALL LOADR40

             CPYF FROMFILE(TTMERG) TOFILE(TTMERGH) MBROPT(*ADD) +
             FMTOPT(*NOCHK)                                       /* (770aA) */

            /* File Cleanup                                            */
/*650 D      CLRPFM     FILE(LDRHDR)*/    /* Clear daily Header           */

/*650 D      CLRPFM     FILE(LDRDETL)*/   /* Clear daily Detail           */

/*650 D      CLRPFM     FILE(LDRDTLBK)*/  /* Clear dly Pcs/Cube DtlBkp    */

/*650 D      CLRPFM     FILE(RTEFLGD)*/   /* Clear Rte flagged Work File  */


             CHGVAR     VAR(&STMT) VALUE('delete from LDRHDR')    /* (650 A) */
             MCSQL      STM(&STMT)                                /* (650 A) */

             CHGVAR     VAR(&STMT) VALUE('delete from LDRDETL')   /* (650 A) */
             MCSQL      STM(&STMT)                                /* (650 A) */

             CHGVAR     VAR(&STMT) VALUE('delete from LDRDTLBK')  /* (650 A) */
             MCSQL      STM(&STMT)                                /* (650 A) */

             CHGVAR     VAR(&STMT) VALUE('delete from RTEFLGD')   /* (650 A) */
             MCSQL      STM(&STMT)                                /* (650 A) */

             CHGVAR     VAR(&STMT) VALUE('delete from TTMERG')    /* (730 A) */
             MCSQL      STM(&STMT)                                /* (730 A) */

             ENDPGM
