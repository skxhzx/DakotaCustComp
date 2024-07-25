     F*----------------------------------------------------------------
     F*   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     F*   BFC Associates
     F*   245 W. Roosevelt Rd.  #8-51
     F*   West Chicago, IL  60185
     F*   (630) 562-0375
     F*----------------------------------------------------------------
     F*
     F*  QDSVL001  Saval - Update Items with Info Imported from Host.
     F*  Max Blacknik
     F*  07 August 2009
     F*
     F*----------------------------------------------------------------
     F*  Revisions
SVL AF*    08/07/09  MLB  SVL
     F*      - Created.
SVLaAF*    08/18/09  MLB  SVLa
     F*      - Enh: Revised program to load shelf life days into Mfg Shelf
     F*        life days field if Date Sensitive and Mfg Dated item.
     F*      - If item not date sensitive, load 10 days into ITSLIF field.
SVLbAF*    08/19/09  MLB  SVLb
     F*      - Revised program to no longer update ITEMFLD field. Category
     F*        code being sent in IMPFITMN file from NDS.
     F*
     F*----------------------------------------------------------------
     C*  Notes:
     F*  Created program to update Items with Info Imported
     F*  Host system that is not available in NDS system.
     F*
     FIMPSVLITM if   e           k disk
     Fpiritem   uf   e           k disk
     Fitemmsc   uf   e           k disk
     Fitemfld   uf a e           k disk
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     *  Main line
     *
     C                   move      '1'           forever           1
     C
     C     *loval        setll     impsvlitm
     C                   dow       forever = forever
     C                   read      impsvlitm
     C                   select
     C                   when      %eof(impsvlitm)
     C                   leave
     C
     C                   other
     C
     C     itkey         chain     piritem
     C                   if        %found(piritem)
     C
     C                   if           svlfgd = 'Y'
     C                             or svlfgd = 'N'
     C                   eval      itflgd = svlfgd
     C                   endif
     C                   eval      itslif = svlslf
     C                   eval      itven# = svlven
     C                   eval      itcube = svlcub
     C                   eval      itulen = svllen
     C                   eval      ituwdt = svlwdt
     C                   eval      ituhgt = svlhgt
     C                   if           svlcwg = 'Y'
     C                             or svlcwg = 'N'
     C                   eval      itcwgt = svlcwg
     C                   endif
     C
     C                   update    itrec
     C                   endif
     C
     C     itkey         chain     itemmsc
     C                   if        %found(itemmsc)
     C
     C                   if           svlfgm = 'Y'
     C                             or svlfgm = 'N'
     C                   eval      immflg = svlfgm
     C                   endif
SVLaAC                   if        immflg = 'Y'
SVLaAC                             and immday = 0
SVLaAC                   eval      immday = svlslf
SVLaAC                   endif
     C                   eval      imvnam = svlvnm
     C                   eval      imdday = svlddy
     C                   eval      imuday = svludy
     C                   eval      imoday = svlody
     C
     C                   update    imrec
     C                   endif
     C
SVLbAC                   goto      skip1
     C
     C     itkey         chain     itemfld
     C                   if        %found(itemfld)
     C                   eval      ifcat  = svlcat
     C                   update    ifrec
     C                   else
     C                   eval      ifwhse = kywhse
     C                   eval      ifitem = svlitm
     C                   eval      ifcat  = svlcat
     C                   write     ifrec
     C                   endif
     *
SVLbAC     skip1         tag
     C                   endsl                                                  Endsl - EOF impsvlit
     C
     C                   enddo                                                  Enddo - Forevrr
     *
SVLaAC     *loval        setll     piritem
SVLaAC                   dow       forever = forever
SVLaAC                   read      piritem
SVLaAC                   select
SVLaAC                   when      %eof(piritem)
SVLaAC                   leave
SVLaAC
SVLaAC                   other
SVLaA*  For all non-date sensitive items, set shelf life to 10 days.
SVLaAC                   if        itflgd = 'N'
SVLaAC                             and itnday = 0
SVLaAC                   eval      itnday = 10
SVLaAC                   update    itrec
SVLaAC                   endif
SVLaAC
SVLaAC                   endsl
SVLaAC                   enddo
     C
     C                   eval      *inlr = *on
     C*
     *----------------------------------------------------------------
     *
     *          Subroutines in Alphabetical Order
     *
     *----------------------------------------------------------------
     C     *inzsr        begsr
     C                   exsr      zzinz
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     C                   move      '001'         kywhse            3 0
     C
     C     itkey         klist
     C                   kfld                    kywhse
     C                   kfld                    svlitm
     C*
     C                   endsr
