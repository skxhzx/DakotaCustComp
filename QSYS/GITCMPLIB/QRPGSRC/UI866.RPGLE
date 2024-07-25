H DEBH debug option(*srcstmt:*nodebugio)
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
510 A*  UI866     Caller ID Program - use with Programs
     *  29 September  2006
     *  Jeffrey Jahnke
     *
     *  Revisions
     *
     *    xx/xx/xx  xxx  x.xx
     *
     *---------------------------------------------------------------------
     * Notes:  Code downloaded from New400.com
     *---------------------------------------------------------------------

     D Qusec           DS
     D  QusBPrv                1      4B 0
     D  QusBAvl                5      8B 0
     D  Qusei                  9     15
     D  Quserved              16     16

      * Type definition for the RCVM0200 format

     D RCVM0200        DS           120
     D  Program              111    120

      *---------------------------------------------------------------------
      * Standalone Field Definitions
      *---------------------------------------------------------------------

      * Program message parameters

     D Pm_MsgId        S              7    Inz(*BLANKS)
     D Pm_MsgF         S             20    Inz(*BLANKS)
     D Pm_MsgDta       S             12    Inz('Who are you?')
     D Pm_Length       S              9B 0
     D Pm_MType        S             10    Inz('*INFO')
     D Pm_MKey         S              4    Inz(*BLANKS)
     D Pm_CSEntry      S             10    Inz('*')
     D Pm_Counter      S              9B 0 Inz

     D Pm_Format       S              8    Inz('RCVM0200')
     D Pm_Wait         S              9B 0 Inz(0)
     D Pm_Action       S             10    Inz('*REMOVE')

      *---------------------------------------------------------------------
      * Parameter Lists
      *---------------------------------------------------------------------

     C     *Entry        PList
     C                   Parm                    Caller           10
     C                   Parm                    Counter          15 5

      *---------------------------------------------------------------------
      * Main Program
      *---------------------------------------------------------------------

      * Set PM_Counter Field

     C                   Z-Add     Counter       PM_Counter

      * Set error code structure not to use exceptions

     C                   Z-Add     16            QusBPrv

      * Set length of message data

     C                   Z-Add     12            Pm_Length

      * Send program message

     C                   Call      'QMHSNDPM'
     C                   Parm                    Pm_MsgId
     C                   Parm                    Pm_MsgF
     C                   Parm                    Pm_MsgDta
     C                   Parm                    Pm_Length
     C                   Parm                    Pm_MType
     C                   Parm                    Pm_CSEntry
     C                   Parm                    Pm_Counter
     C                   Parm                    Pm_MKey
     C                   Parm                    Qusec

      * Check for errors

     C                   If        QusBAvl > 0
     C                   Exsr      *PSSR
     C                   EndIf

      * Clear return data structure

     C                   Clear                   RCVM0200

      * Set length of message information

     C                   Z-Add     120           Pm_Length

      * Receive program message

     C                   Call      'QMHRCVPM'
     C                   Parm                    RCVM0200
     C                   Parm                    Pm_Length
     C                   Parm                    Pm_Format
     C                   Parm                    Pm_CSEntry
     C                   Parm                    Pm_Counter
     C                   Parm                    Pm_MType
     C                   Parm                    Pm_MKey
     C                   Parm                    Pm_Wait
     C                   Parm                    Pm_Action
     C                   Parm                    Qusec

      * Check for errors
     C                   If        QusBAvl > 0
     C                   Exsr      *PSSR
     C                   EndIf

     C                   Move      Program       Caller
     C                   Return

      *---------------------------------------------------------------------
      * *PSSR - Error Handling Subroutine
      *---------------------------------------------------------------------

     C     *PSSR         Begsr
     C                   Return
     C                   Endsr
