/*-------------------------------------------------------------------*/
/*                                                                   */
/*  GETLBLCL   Get labels for OR620 Build Pallet Routine             */
/*  27 October,  2008                                                */
/*  Jeffrey Jahnke                                                   */
/*                                                                   */
/*  Revisions                                                        */
/*    10/25/08  JCJ  5.20                                            */
/*      - Created                                                    */
/*                                                                   */
/*-------------------------------------------------------------------*/

 GETLBLCL:   PGM        PARM(&PWHSE &PRTE &PCOMP &PTZON &PGEN &PSZON +
                          &PTYPE)

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

  /* File name.   */

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(10) VALUE(OR620)

  /* Get program. */

             DCL        VAR(&OPTPGM) TYPE(*CHAR) LEN(9) +
                          VALUE(GETLABELS)

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&PWHSE)      TYPE(*CHAR) LEN(3)
             DCL        VAR(&PRTE)       TYPE(*CHAR) LEN(5)
             DCL        VAR(&PCOMP)      TYPE(*CHAR) LEN(1)
             DCL        VAR(&PTZON)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&PGEN)       TYPE(*CHAR) LEN(1)
             DCL        VAR(&PSZON)      TYPE(*CHAR) LEN(6)
             DCL        VAR(&PTYPE)      TYPE(*CHAR) LEN(1)
             DCL        VAR(&MEMBER)     TYPE(*CHAR) LEN(10)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

/*  Get Labels          */

             CALL       PGM(&OPTPGM) PARM(&PWHSE &PRTE &PCOMP &PTZON +
                          &PGEN &PSZON &PTYPE)

 GETOUT:     ENDPGM
