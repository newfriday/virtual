.set    BaseOfLoader,               0x9000
.set    OffsetOfLoader,             0x100
.set    RootDirSectors,             14 
.set    SectorNoOfRootDirectory,    19 
.set    BaseOfStack,                0x180
# DeltaSectorNo = BPB_RsvdSecCnt + (BPB_NumFATs * FATSz) - 2
# 文件的开始Sector号 = DirEntry中的开始Sector号 + 根目录占用Sector数目 + DeltaSectorNo
.set    DeltaSectorNo,              17
.set    SectorNoOfFAT1,             1
.set    BaseOfStack,                0x7c00
