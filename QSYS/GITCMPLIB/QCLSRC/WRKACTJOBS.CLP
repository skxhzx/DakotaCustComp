/*********************************************************************/
/* PROGRAM:   WRKACTJOBS                                             */
/*                                                                   */
/* AUTHOR:    POUL ASCHENBRENNER, COOP DATA                          */
/*                                                                   */
/* FUNCTION:  OUTPUT WORK ACTIVE JOBS TO FILE.                       */
/*                                                                   */
/* PARM:      1. SUBSYSTEM                                           */
/*            2. JOB NAME                                            */
/*********************************************************************/
             PGM        PARM(&SBS &JOB)
             DCL        VAR(&SBS) TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOB) TYPE(*CHAR) LEN(10)
             DCL        VAR(&CMD) TYPE(*CHAR) LEN(80)
             DLTF       FILE(QTEMP/WRKACTJOBS)
             MONMSG     MSGID(CPF0000)
             CRTPF      FILE(QTEMP/WRKACTJOBS) RCDLEN(266)
             MONMSG     MSGID(CPF0000)
             CHGVAR     VAR(&CMD) VALUE('SYSTEM "WRKACTJOB SBS(' *TCAT +
                          &SBS *TCAT ') JOB(' *TCAT &JOB *TCAT ')"')
        /*   SNDPGMMSG  MSG('OUTPUT FOR WRKACTJOB SEND TO +
                         QTEMP/WRKACTJOBS...')      */
             OVRDBF     FILE(STDOUT) TOFILE(QTEMP/WRKACTJOBS)
             STRQSH     CMD(&CMD)
             ENDPGM
