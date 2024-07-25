/*-------------------------------------------------------------------*/
/*                                                                   */
/*  QDEFC001CL   Q&D Refresh PIRTESTF (item/qty files) from PIRF     */
/*                                                                   */
/*  25 February 2014                                                 */
/*  Max Blacknik                                                     */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*  Revisions                                                        */
/*                                                                   */
/*    02/25/14  MLB  EFC                                             */
/*      - Created.                                                   */
/*    03/18/14  MLB  EFCa                                            */
/*      - Fix: Revised pgm to set &PITEM = *ALL just before call     */
/*        to UT812 to re-calc item warehouse qty.                    */
/*                                                                   */
/*-------------------------------------------------------------------*/

 QDEFC001CL:    PGM

/*-------------------------------------------------------------------*/
/*  Constant declarations                                            */
/*-------------------------------------------------------------------*/

/*-------------------------------------------------------------------*/
/*  Field declarations                                               */
/*-------------------------------------------------------------------*/

             DCL        VAR(&ENV)        TYPE(*CHAR) LEN(5)
             DCL        VAR(&errmsg)     TYPE(*CHAR) LEN(500)
             DCL        VAR(&pwhs)       TYPE(*DEC)  LEN(15 5)
             DCL        VAR(&pitem)      TYPE(*CHAR) LEN(15)
             DCL        VAR(&pjobq)      TYPE(*CHAR) LEN(1)
             DCL        VAR(&pprg)       TYPE(*CHAR) LEN(10)

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

             CPYF       FROMFILE(PIRF/ITEMQTY) +
                          TOFILE(PIRTESTF/ITEMQTY) MBROPT(*REPLACE)
             MONMSG     MSGID(CPF0001) EXEC(DO)

               CHGVAR     VAR(&ERRMSG) VALUE('CPYF failed while +
                            copying ITEMQTY. Re-run QDEFC001CL.')
               GOTO       CMDLBL(#SNDERRMSG)
             ENDDO

             CPYF       FROMFILE(PIRF/PIRITEM) +
                          TOFILE(PIRTESTF/PIRITEM) MBROPT(*REPLACE)
             MONMSG     MSGID(CPF0001) EXEC(DO)

               CHGVAR     VAR(&ERRMSG) VALUE('CPYF failed while +
                            copying PIRITEM. Re-run QDEFC001CL.')
               GOTO       CMDLBL(#SNDERRMSG)
             ENDDO

             CPYF       FROMFILE(PIRF/ITEMMSC) +
                          TOFILE(PIRTESTF/ITEMMSC) MBROPT(*REPLACE)
             MONMSG     MSGID(CPF0001) EXEC(DO)

               CHGVAR     VAR(&ERRMSG) VALUE('CPYF failed while +
                            copying ITEMMSC. Re-run QDEFC001CL.')
               GOTO       CMDLBL(#SNDERRMSG)
             ENDDO

             CPYF       FROMFILE(PIRF/ITEMFLD) +
                          TOFILE(PIRTESTF/ITEMFLD) MBROPT(*REPLACE)
             MONMSG     MSGID(CPF0001) EXEC(DO)

               CHGVAR     VAR(&ERRMSG) VALUE('CPYF failed while +
                            copying ITEMFLD. Re-run QDEFC001CL.')
               GOTO       CMDLBL(#SNDERRMSG)
             ENDDO

             CPYF       FROMFILE(PIRF/ITEMEXT) +
                          TOFILE(PIRTESTF/ITEMEXT) MBROPT(*REPLACE)
             MONMSG     MSGID(CPF0001 CPF2869 CPF2817) EXEC(DO)

/*               GOTO       CMDLBL(#SNDERRMSG)  ignore copy failure.     */
             ENDDO

             CPYF       FROMFILE(PIRF/ITEMDSC) +
                          TOFILE(PIRTESTF/ITEMDSC) MBROPT(*REPLACE)
             MONMSG     MSGID(CPF0001) EXEC(DO)

               CHGVAR     VAR(&ERRMSG) VALUE('CPYF failed while +
                            copying ITEMDSC. Re-run QDEFC001CL.')
               GOTO       CMDLBL(#SNDERRMSG)
             ENDDO

             CPYF       FROMFILE(PIRF/ITEMLNK) +
                          TOFILE(PIRTESTF/ITEMLNK) MBROPT(*REPLACE)
             MONMSG     MSGID(CPF0001) EXEC(DO)

               CHGVAR     VAR(&ERRMSG) VALUE('CPYF failed while +
                            copying ITEMLNK. Re-run QDEFC001CL.')
               GOTO       CMDLBL(#SNDERRMSG)
             ENDDO

             CPYF       FROMFILE(PIRF/KITCOMP) +
                          TOFILE(PIRTESTF/KITCOMP) MBROPT(*REPLACE)
             MONMSG     MSGID(CPF0001) EXEC(DO)

               CHGVAR     VAR(&ERRMSG) VALUE('CPYF failed while +
                            copying KITCOMP. Re-run QDEFC001CL.')
               GOTO       CMDLBL(#SNDERRMSG)
             ENDDO

             CPYF       FROMFILE(PIRF/KITITEM) +
                          TOFILE(PIRTESTF/KITITEM) MBROPT(*REPLACE)
             MONMSG     MSGID(CPF0001) EXEC(DO)

               CHGVAR     VAR(&ERRMSG) VALUE('CPYF failed while +
                            copying KITITEM. Re-run QDEFC001CL.')
               GOTO       CMDLBL(#SNDERRMSG)
             ENDDO

             CPYF       FROMFILE(PIRF/SLOT) TOFILE(PIRTESTF/SLOT) +
                          MBROPT(*REPLACE)
             MONMSG     MSGID(CPF0001) EXEC(DO)

               CHGVAR     VAR(&ERRMSG) VALUE('CPYF failed while +
                            copying SLOT. Re-run QDEFC001CL.')
               GOTO       CMDLBL(#SNDERRMSG)
             ENDDO

             CPYF       FROMFILE(PIRF/VSLOT) TOFILE(PIRTESTF/VSLOT) +
                          MBROPT(*REPLACE)
             MONMSG     MSGID(CPF0001) EXEC(DO)

               CHGVAR     VAR(&ERRMSG) VALUE('CPYF failed while +
                            copying VSLOT. Re-run QDEFC001CL.')
               GOTO       CMDLBL(#SNDERRMSG)
             ENDDO

             CPYF       FROMFILE(PIRF/LICACTIVE) +
                          TOFILE(PIRTESTF/LICACTIVE) MBROPT(*REPLACE)
             MONMSG     MSGID(CPF0001) EXEC(DO)

               CHGVAR     VAR(&ERRMSG) VALUE('CPYF failed while +
                            copying LICACTIVE. Re-run QDEFC001CL.')
               GOTO       CMDLBL(#SNDERRMSG)
             ENDDO

/*    Run Re-Calc Whse Qty from Slots after successful copy of all item/qty file
             chgvar     VAR(&PWHS) VALUE(001)
             chgvar     VAR(&PITEM) VALUE('*ALL')                 /* (EFCaA) */
             chgvar     var(&pjobq) value('Y')
             chgvar     var(&pprg) value('QDEFC001CL')
             CALL       PGM(UT812) PARM(&PWHS &PITEM &pJOBQ &pprg ' ' ' ')
             SNDPGMMSG  MSG('Refresh of PIRTESTF from PIRF completed +
                          successfully.') TOMSGQ(BFC)

#snderrmsg:
             SNDPGMMSG  MSG(&ERRMSG) TOMSGQ(BFC)

             ENDPGM
