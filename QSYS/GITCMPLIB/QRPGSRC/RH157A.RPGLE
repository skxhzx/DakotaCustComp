      /copy qcopysrc,hspecs
     F*----------------------------------------------------------------
     F*   Copyright (C) 2002 BFC Software, Inc. - All Rights Reserved
     F*----------------------------------------------------------------
     F*
     F*  RH157A    Write dummy record to FTP export file.
     F*  March 19, 2019
     F*  Rod Roller
     F*
     F*----------------------------------------------------------------
     F*  Revisions
     F*
730a F*    03/19/19  RTR  7.30
     F*      - Created from RH157.
     F*
     F*----------------------------------------------------------------
     F* Notes
     F*
     F*   In a situation where there are no records to be retrieved
     F*   we need to let the host system know the reason. In an FTP
     F*   situation we don't want to cause an error because the host
     F*   system would then start to ignore all errors. Therefore,
     F*   we create a single record in the header file that identifies
     F*   the reason why no orders were retreived.
     F*
     F*   Two reasons would be that nothing has been exported yet and
     F*   another would be that someone is currently doing an export
     F*   from within Truck Builder.
     F*
     F*----------------------------------------------------------------
     F* File Specs
     F*
     FEXPFORDH2 O  A E           K DISK
     D*----------------------------------------------------------------
     D*  Customer id
     D*
     D @GETCL          C                   CONST('GETCLIENT')
     C*----------------------------------------------------------------
     C*  Parameters
     C*
     C*    Input Parameters
     C*      $PTYPE  Code put into customer name field to identify
     C*              certain conditions (e.g., *NORECS*).
     C*
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     C     *ENTRY        PLIST
     C                   PARM                    $PTYPE           10
     C*
     C* Get client id.
     C*
     C                   CALL      @GETCL
     C                   PARM                    CLIENT           10
     C                   PARM                    CLILOC           10
     C*
     C* Main line
     C*
     C                   CLEAR                   OEHREC
     C                   MOVEL(P)  $PTYPE        OEHCNM
     C                   WRITE     OEHREC
     C*
     C                   MOVE      *ON           *INLR
