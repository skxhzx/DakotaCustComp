/*********************************************************************/
/*                                                                   */
/*  OR770MSG  Send message that OR770 printed.                       */
/*  16 January 2001                                                  */
/*  Dave Sommerville                                                 */
/*                                                                   */
/*********************************************************************/

 OR770MSG:   PGM

             DCL        VAR(&MSG)       TYPE(*CHAR) LEN(128)
             DCL        VAR(&USER)      TYPE(*CHAR) LEN(10)

             RTVDTAARA  DTAARA(OR770USER) RTNVAR(&USER)

             IF (&USER *EQ ' ') THEN(DO)
               CHGVAR VAR(&USER) VALUE('*SYSOPR')
             ENDDO

             CHGVAR VAR(&MSG) VALUE('Host will call exception report +
                          (OR770PR) printed. Please review and make +
                          necessary corrections.')

             SNDUSRMSG  MSG(&MSG) MSGTYPE(*INFO) TOUSR(&USER)
             MONMSG     MSGID(CPF2559) EXEC(DO)
               SNDUSRMSG  MSG(&MSG) MSGTYPE(*INFO) TOUSR(*SYSOPR)
             ENDDO
             MONMSG     MSGID(CPF2559)

             ENDPGM
