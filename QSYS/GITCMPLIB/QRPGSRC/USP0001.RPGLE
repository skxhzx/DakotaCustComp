      *****************************************************************
      *
      * Program Name: USP0001 - Create/Delete User Space
      * Author: Thomas D. Chamberlain - 3X Corporation
      * Date: April 23rd 1998
      *
      *****************************************************************
      * Parameters:
      *
      *    Create/Delete          - Required
      *    User Space Name        - Required
      *    User Space Library     - Optional  - Default = QTEMP
      *
      *
      *****************************************************************
      * Program Information
     D                SDS
     D PGM_PARMS         *PARMS
     D PGM_PROCS         *PROC
     D PGM_ROUTNE        *ROUTINE
     D PGM_STATUS        *STATUS
      * Input Parameters
     D MODE            S              7
     D SPACE_NAME      S             10
     D SPACE_LIBL      S             10
      *****************************************************************
      *Standard Parameters for User Space
      *****************************************************************
     DQUAL_SPACE       DS
     D SPC_NAME                1     10
     D SPC_LIB                11     20    INZ('QTEMP')
      * Attibute
     D SPC_ATR         S             10    INZ('SPACE')
      * Initial Size
     D SPC_INIT_S      S              9B 0 INZ(1)
      * Initial Value
     D SPC_INIT_V      S              1    INZ(X'00')
      * Authoritie
     D SPC_AUTH        S             10    INZ('*ALL')
      * Text
     D SPC_TEXT        S             50
      * Replace
     D SPC_REPLAC      S             10    INZ('*YES')
      * Returned Library
     D SPC_RTN_L       S             10
      * Attribute to Change
     DSPC_ATR_CH       DS
     D SPC_ATR_NB                     9B 0 INZ(1)
     D SPC_ATR_KE                     9B 0 INZ(3)
     D SPC_ATR_LT                     9B 0 INZ(1)
     D SPC_ATR_DT                     1    INZ('1')
      *****************************************************************
      *Record structure for Error Code Parameter
      *****************************************************************
     DQUSEC            DS
     D*                                             Qus EC
     D QUSBPRV                 1      4B 0
     D*                                             Bytes Provided
     D QUSBAVL                 5      8B 0
     D*                                             Bytes Available
     D QUSEI                   9     15
     D*                                             Exception Id
     D QUSERVED               16     16
     D*                                             Reserved
     D QUSED01                17     17
     D*                                      Varying length
     D Error_Msg       S             50
      *****************************************************************
      * Get Parameters
     C     *ENTRY        PLIST
     C                   PARM                    MODE
     C                   PARM                    SPACE_NAME
     C                   PARM                    SPACE_LIBL
      * No Parms/Need More Parms
     C                   If        PGM_PARMS >= 2
      * User Space Name Given
     C                   If        PGM_PARMS = 2
     C                   Eval      SPC_NAME = SPACE_NAME
     C                   Endif
      * Library for User Space Given
     C                   If        PGM_PARMS = 3
     C                   Eval      SPC_LIB = SPACE_LIBL
     C                   Endif
      * Create Mode
     C                   If        Mode = '*CREATE'
     C                   Exsr      $Create_Sp
     C                   Endif
      * Delete Mode
     C                   If        Mode = '*DELETE'
     C                   Exsr      $Delete_Sp
     C                   Endif
      *
     C                   Endif
      * End Program
     C                   Eval      *INLR = *On
     C                   Return
      *****************************************************************
      * Create and Extend User Space
      *****************************************************************
     C     $Create_Sp    Begsr
      * Create the User Space
     C                   CALL      'QUSCRTUS'
     C                   PARM                    QUAL_SPACE
     C                   PARM                    SPC_ATR
     C                   PARM                    SPC_INIT_S
     C                   PARM                    SPC_INIT_V
     C                   PARM                    SPC_AUTH
     C                   PARM                    SPC_TEXT
     C                   PARM                    SPC_REPLAC
     C                   PARM                    QUSEC
      * Check for Errors
     C                   If        QUSEI <> *Blanks
     C                   Eval      Error_Msg = 'Create Space Error: ' + QUSEI
     C     Error_Msg     Dsply
     C                   Endif
      * Set the User Space to Automatic Extendibility
     C                   CALL      'QUSCUSAT'
     C                   PARM                    SPC_RTN_L
     C                   PARM                    QUAL_SPACE
     C                   PARM                    SPC_ATR_CH
     C                   PARM                    QUSEC
      * Check for Errors
     C                   If        QUSEI <> *Blanks
     C                   Eval      Error_Msg = 'Change Space Error: ' + QUSEI
     C     Error_Msg     Dsply
     C                   Endif
      *
     C                   Endsr
      *****************************************************************
      * Delete User Space
      *****************************************************************
     C     $Delete_Sp    Begsr
      * Delete the User Space
     C                   CALL      'QUSDLTUS'
     C                   PARM                    QUAL_SPACE
     C                   PARM                    QUSEC
      * Check for Errors
     C                   If        QUSEI <> *Blanks
     C                   Eval      Error_Msg = 'Delete Space Error: ' + QUSEI
     C     Error_Msg     Dsply
     C                   Endif
      *
     C                   Endsr
