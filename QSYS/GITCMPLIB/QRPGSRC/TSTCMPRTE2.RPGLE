      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *  TSTCMPRTE2    Test TRCMPRTE2
     *  17 August 2017
     *  Dave Sommerville
     *----------------------------------------------------------------

     d  fldLen         s              3  0
     d  pVersion       s              5    varying
     d  pCommand       s             30    varying
     d  pEmpNo         s              5    varying
     d  pWhse          s              3    varying
     d  pRtid          s              5    varying
     d  pStop          s              5    varying
     d  pPath          s            100    varying
     d  pFile          s            100    varying
     d  pStamp         s             19    varying
     d  pLatitude      s             15    varying
     d  pLongitude     s             15    varying
     d  pRtnCode       s             10    varying
     d  pRtnMsg        s             60    varying

     d trcmprte2       pr                  extpgm('TRCMPRTE2')
     d  pVersion                      5    varying const
     d  pCommand                     30    varying const
     d  pEmpNo                        5    varying const
     d  pWhse                         3    varying const
     d  pRtid                         5    varying const
     d  pStop                         5    varying const
     d  pPath                       100    varying const
     d  pFile                       100    varying const
     d  pStamp                       19    varying const
     d  pLatitude                    15    varying const
     d  pLongitude                   15    varying const
     d  pRtnCode                     10    varying
     d  pRtnMsg                      60    varying

      /free

        *inlr = *on;

        pVersion = '2.00';
        pCommand = 'SomeCommand';
        pEmpNo = '12345';
        pWhse = '900';
        pRtid = '54321';
        pStop = '02';
        pPath = '/path/to/file';
        pFile = 'filename.xml';
        pStamp = '2017-08-17T10:11:12';
        pLatitude = '41.884751';
        pLongitude = '-88.203961';
        pRtnCode = '';
        pRtnMsg = '';

       trcmprte2(
        pVersion:
        'SomeOtherCommand':
        pEmpNo:
        pWhse:
        pRtid:
        pStop:
        pPath:
        pFile:
        pStamp:
        pLatitude:
        pLongitude:
        pRtnCode:
        pRtnMsg);

       trcmprte2(
        pVersion:
        'TEST':
        pEmpNo:
        pWhse:
        pRtid:
        pStop:
        pPath:
        pFile:
        pStamp:
        pLatitude:
        pLongitude:
        pRtnCode:
        pRtnMsg);

        fldLen = %len(pRtnCode);
        return;
      /end-free
