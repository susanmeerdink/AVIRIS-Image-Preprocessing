PRO aviris_apply_correction_batch
;This code applies a correction to aviris imagery from the santa barbara flightbox
;Atmospheric correction on teh AVIRIS images varies quite a bit from date to date
;Using the Storke Post Office ASD spectra and spectra from FL06, I have derived a multiplying factor for each date
;See file Determining AVIRIS Correction Factors for details
;This code will also updated the band names, wavelengths, and bad band list so that all file will have the same
;Output image will have all Bad Bands with a value of 0
;Susan Meerdink
;3/13/17
;----------------------------------------------------------------------
;;; SETTING UP ENVI/IDL ENVIRONMENT ;;;
COMPILE_OPT STRICTARR
envi, /restore_base_save_files
ENVI_BATCH_INIT ;Doesn't require having ENVI open - use with stand alone IDL 64 bit

;;; INPUTS ;;;
main_path = 'F:\Image-To-Image-Registration\AVIRIS\' ; Set directory that holds all flightlines
;fl_list = ['FL02','FL03','FL04','FL05','FL06','FL07','FL08','FL09','FL10','FL11'] ;Create the list of folders
fl_list = ['FL07','FL08','FL09','FL10','FL11'] ;Create the list of folders

;;; ADDITIONAL VARIABLES ;;;
badbandList = [0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0]
wavelengthList = [365.91,375.58,385.25,394.92,404.60,414.28,423.96,433.65,443.35,453.05,462.75,472.46,482.17,491.89,501.61,511.34,521.07,530.80,540.54,550.28,560.03,569.78,579.54,589.30,599.07,608.84,618.61,628.39,638.17,647.96,657.75,667.54,655.48,665.28,675.08,684.88,694.67,704.46,714.24,724.02,733.79,743.55,753.31,763.07,772.82,782.56,792.30,802.04,811.76,821.49,831.21,840.92,850.63,860.33,870.03,879.72,889.41,899.09,908.77,918.44,928.10,937.77,947.42,957.07,966.72,976.36,985.99,995.62,1005.25,1014.86,1024.48,1034.09,1043.69,1053.29,1062.88,1072.47,1082.06,1091.63,1101.21,1110.77,1120.34,1129.89,1139.44,1148.99,1158.53,1168.07,1177.60,1187.13,1196.65,1206.16,1215.67,1225.18,1234.68,1244.17,1253.66,1263.14,1253.35,1263.33,1273.30,1283.27,1293.24,1303.21,1313.19,1323.16,1333.13,1343.10,1353.07,1363.04,1373.01,1382.98,1392.95,1402.92,1412.89,1422.86,1432.83,1442.79,1452.76,1462.73,1472.70,1482.66,1492.63,1502.60,1512.57,1522.53,1532.50,1542.46,1552.43,1562.40,1572.36,1582.33,1592.29,1602.26,1612.22,1622.18,1632.15,1642.11,1652.07,1662.04,1672.00,1681.96,1691.93,1701.89,1711.85,1721.81,1731.77,1741.73,1751.69,1761.66,1771.62,1781.58,1791.54,1801.50,1811.45,1821.41,1831.37,1841.33,1851.29,1861.25,1871.21,1872.36,1866.84,1876.91,1886.96,1897.02,1907.08,1917.13,1927.18,1937.23,1947.27,1957.31,1967.36,1977.39,1987.43,1997.46,2007.50,2017.52,2027.55,2037.58,2047.60,2057.62,2067.64,2077.65,2087.66,2097.68,2107.68,2117.69,2127.69,2137.70,2147.69,2157.69,2167.69,2177.68,2187.67,2197.66,2207.64,2217.63,2227.61,2237.58,2247.56,2257.53,2267.51,2277.48,2287.44,2297.41,2307.37,2317.33,2327.29,2337.24,2347.20,2357.15,2367.09,2377.04,2386.99,2396.93,2406.87,2416.80,2426.74,2436.67,2446.60,2456.53,2466.45,2476.38,2486.30,2496.22]
bandnameList = {'Band 1 (365.91)','Band 2 (375.58)','Band 3 (385.25)','Band 4 (394.92)','Band 5 (404.6)','Band 6 (414.28)','Band 7 (423.96)','Band 8 (433.65)','Band 9 (443.35)','Band 10 (453.05)','Band 11 (462.75)','Band 12 (472.46)','Band 13 (482.17)','Band 14 (491.89)','Band 15 (501.61)','Band 16 (511.34)','Band 17 (521.07)','Band 18 (530.8)','Band 19 (540.54)','Band 20 (550.28)','Band 21 (560.03)','Band 22 (569.78)','Band 23 (579.54)','Band 24 (589.3)','Band 25 (599.07)','Band 26 (608.84)','Band 27 (618.61)','Band 28 (628.39)','Band 29 (638.17)','Band 30 (647.96)','Band 31 (657.75)','Band 32 (667.54)','Band 33 (655.48)','Band 34 (665.28)','Band 35 (675.08)','Band 36 (684.88)','Band 37 (694.67)','Band 38 (704.46)','Band 39 (714.24)','Band 40 (724.02)','Band 41 (733.79)','Band 42 (743.55)','Band 43 (753.31)','Band 44 (763.07)','Band 45 (772.82)','Band 46 (782.56)','Band 47 (792.3)','Band 48 (802.04)','Band 49 (811.76)','Band 50 (821.49)','Band 51 (831.21)','Band 52 (840.92)','Band 53 (850.63)','Band 54 (860.33)','Band 55 (870.03)','Band 56 (879.72)','Band 57 (889.41)','Band 58 (899.09)','Band 59 (908.77)','Band 60 (918.44)','Band 61 (928.1)','Band 62 (937.77)','Band 63 (947.42)','Band 64 (957.07)','Band 65 (966.72)','Band 66 (976.36)','Band 67 (985.99)','Band 68 (995.62)','Band 69 (1005.25)','Band 70 (1014.86)','Band 71 (1024.48)','Band 72 (1034.09)','Band 73 (1043.69)','Band 74 (1053.29)','Band 75 (1062.88)','Band 76 (1072.47)','Band 77 (1082.06)','Band 78 (1091.63)','Band 79 (1101.21)','Band 80 (1110.77)','Band 81 (1120.34)','Band 82 (1129.89)','Band 83 (1139.44)','Band 84 (1148.99)','Band 85 (1158.53)','Band 86 (1168.07)','Band 87 (1177.6)','Band 88 (1187.13)','Band 89 (1196.65)','Band 90 (1206.16)','Band 91 (1215.67)','Band 92 (1225.18)','Band 93 (1234.68)','Band 94 (1244.17)','Band 95 (1253.66)','Band 96 (1263.14)','Band 97 (1253.35)','Band 98 (1263.33)','Band 99 (1273.3)','Band 100 (1283.27)','Band 101 (1293.24)','Band 102 (1303.21)','Band 103 (1313.19)','Band 104 (1323.16)','Band 105 (1333.13)','Band 106 (1343.1)','Band 107 (1353.07)','Band 108 (1363.04)','Band 109 (1373.01)','Band 110 (1382.98)','Band 111 (1392.95)','Band 112 (1402.92)','Band 113 (1412.89)','Band 114 (1422.86)','Band 115 (1432.83)','Band 116 (1442.79)','Band 117 (1452.76)','Band 118 (1462.73)','Band 119 (1472.7)','Band 120 (1482.66)','Band 121 (1492.63)','Band 122 (1502.6)','Band 123 (1512.57)','Band 124 (1522.53)','Band 125 (1532.5)','Band 126 (1542.46)','Band 127 (1552.43)','Band 128 (1562.4)','Band 129 (1572.36)','Band 130 (1582.33)','Band 131 (1592.29)','Band 132 (1602.26)','Band 133 (1612.22)','Band 134 (1622.18)','Band 135 (1632.15)','Band 136 (1642.11)','Band 137 (1652.07)','Band 138 (1662.04)','Band 139 (1672)','Band 140 (1681.96)','Band 141 (1691.93)','Band 142 (1701.89)','Band 143 (1711.85)','Band 144 (1721.81)','Band 145 (1731.77)','Band 146 (1741.73)','Band 147 (1751.69)','Band 148 (1761.66)','Band 149 (1771.62)','Band 150 (1781.58)','Band 151 (1791.54)','Band 152 (1801.5)','Band 153 (1811.45)','Band 154 (1821.41)','Band 155 (1831.37)','Band 156 (1841.33)','Band 157 (1851.29)','Band 158 (1861.25)','Band 159 (1871.21)','Band 160 (1872.36)','Band 161 (1866.84)','Band 162 (1876.91)','Band 163 (1886.96)','Band 164 (1897.02)','Band 165 (1907.08)','Band 166 (1917.13)','Band 167 (1927.18)','Band 168 (1937.23)','Band 169 (1947.27)','Band 170 (1957.31)','Band 171 (1967.36)','Band 172 (1977.39)','Band 173 (1987.43)','Band 174 (1997.46)','Band 175 (2007.5)','Band 176 (2017.52)','Band 177 (2027.55)','Band 178 (2037.58)','Band 179 (2047.6)','Band 180 (2057.62)','Band 181 (2067.64)','Band 182 (2077.65)','Band 183 (2087.66)','Band 184 (2097.68)','Band 185 (2107.68)','Band 186 (2117.69)','Band 187 (2127.69)','Band 188 (2137.7)','Band 189 (2147.69)','Band 190 (2157.69)','Band 191 (2167.69)','Band 192 (2177.68)','Band 193 (2187.67)','Band 194 (2197.66)','Band 195 (2207.64)','Band 196 (2217.63)','Band 197 (2227.61)','Band 198 (2237.58)','Band 199 (2247.56)','Band 200 (2257.53)','Band 201 (2267.51)','Band 202 (2277.48)','Band 203 (2287.44)','Band 204 (2297.41)','Band 205 (2307.37)','Band 206 (2317.33)','Band 207 (2327.29)','Band 208 (2337.24)','Band 209 (2347.2)','Band 210 (2357.15)','Band 211 (2367.09)','Band 212 (2377.04)','Band 213 (2386.99)','Band 214 (2396.93)','Band 215 (2406.87)','Band 216 (2416.8)','Band 217 (2426.74)','Band 218 (2436.67)','Band 219 (2446.6)','Band 220 (2456.53)','Band 221 (2466.45)','Band 222 (2476.38)','Band 223 (2486.3)','Band 224 (2496.22)'}
cor130411 = [0.00,0.00,1.17,1.11,1.22,1.27,1.26,1.22,1.20,1.16,1.13,1.08,1.05,1.04,1.03,1.04,1.04,1.06,1.07,1.09,1.11,1.13,1.15,1.15,1.15,1.15,1.14,1.13,1.12,1.11,1.10,1.10,1.06,1.06,1.07,1.08,1.07,1.07,1.08,1.07,1.06,1.05,1.06,1.05,1.04,1.05,1.06,1.06,1.05,1.07,1.07,1.06,1.05,1.04,1.04,1.04,1.04,1.04,1.06,1.10,1.03,1.04,1.17,1.07,1.02,1.06,1.05,1.07,1.07,1.06,1.06,1.06,1.06,1.06,1.06,1.06,1.07,1.06,1.06,1.10,1.16,1.13,1.16,1.11,1.08,1.08,1.09,1.09,1.09,1.10,1.10,1.10,1.10,1.10,1.11,1.12,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,1.53,1.45,1.44,1.36,1.26,1.20,1.17,1.15,1.14,1.12,1.11,1.10,1.10,1.10,1.09,1.09,1.09,1.09,1.10,1.10,1.11,1.12,1.12,1.12,1.12,1.12,1.13,1.14,1.16,1.18,1.22,1.27,1.33,1.40,1.37,1.50,1.81,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,1.76,1.66,1.83,2.03,1.52,1.35,1.35,1.37,1.35,1.32,1.27,1.30,1.29,1.30,1.28,1.28,1.29,1.29,1.27,1.24,1.23,1.19,1.16,1.14,1.16,1.20,1.21,1.23,1.27,1.29,1.29,1.29,1.29,1.27,1.32,1.29,1.33,1.35,1.34,1.41,1.43,1.48,1.45,1.57,1.70,1.72,1.85,2.07,2.23,2.77,0.00,0.00,0.00]
cor130606 = [0.00,0.00,0.81,0.86,1.00,1.09,1.10,1.09,1.08,1.05,1.03,0.99,0.96,0.95,0.95,0.95,0.95,0.96,0.98,1.00,1.02,1.03,1.05,1.05,1.04,1.04,1.03,1.02,1.01,1.00,0.99,0.98,0.96,0.96,0.96,0.96,0.96,0.95,0.96,0.95,0.95,0.94,0.94,0.94,0.93,0.94,0.94,0.94,0.93,0.95,0.95,0.94,0.92,0.92,0.92,0.92,0.91,0.91,0.93,0.97,0.89,0.89,1.04,0.95,0.90,0.93,0.92,0.93,0.93,0.93,0.93,0.93,0.92,0.92,0.92,0.92,0.93,0.92,0.92,0.95,0.99,0.99,1.00,0.97,0.96,0.95,0.94,0.94,0.94,0.95,0.95,0.96,0.96,0.96,0.96,0.96,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,1.34,1.25,1.26,1.19,1.10,1.03,1.00,0.98,0.96,0.94,0.94,0.93,0.93,0.92,0.92,0.92,0.92,0.92,0.92,0.92,0.93,0.93,0.93,0.93,0.94,0.94,0.95,0.95,0.97,0.98,1.02,1.06,1.13,1.20,1.19,1.33,1.62,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,1.39,1.32,1.27,1.01,1.05,1.09,1.09,1.07,1.02,1.02,1.03,1.04,1.04,1.03,1.03,1.02,1.04,1.03,1.02,1.00,0.99,0.96,0.94,0.94,0.95,0.98,0.98,1.00,1.03,1.04,1.05,1.04,1.04,1.03,1.05,1.06,1.06,1.09,1.11,1.15,1.14,1.19,1.21,1.28,1.44,1.47,1.58,1.69,2.01,2.41,0.00,0.00,0.00]
cor131125 = [0.00,0.00,1.94,1.33,1.31,1.33,1.30,1.24,1.20,1.14,1.10,1.06,1.02,1.00,0.99,0.99,0.99,1.00,1.01,1.03,1.04,1.06,1.08,1.07,1.07,1.07,1.07,1.06,1.05,1.05,1.04,1.04,1.01,1.01,1.02,1.03,1.03,1.03,1.05,1.04,1.05,1.05,1.05,1.05,1.06,1.06,1.06,1.07,1.06,1.08,1.08,1.08,1.07,1.07,1.07,1.07,1.06,1.07,1.09,1.12,1.06,1.09,1.17,1.09,1.05,1.08,1.08,1.10,1.10,1.09,1.10,1.11,1.10,1.11,1.11,1.11,1.12,1.11,1.10,1.15,1.21,1.19,1.20,1.17,1.14,1.15,1.15,1.16,1.16,1.18,1.17,1.18,1.18,1.19,1.21,1.25,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,1.48,1.44,1.44,1.36,1.28,1.23,1.20,1.19,1.18,1.16,1.15,1.15,1.15,1.14,1.13,1.13,1.14,1.13,1.15,1.15,1.16,1.17,1.17,1.16,1.17,1.16,1.17,1.18,1.19,1.22,1.25,1.30,1.35,1.41,1.38,1.52,1.86,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,1.62,1.56,1.48,1.36,1.32,1.32,1.30,1.28,1.25,1.25,1.26,1.26,1.26,1.26,1.25,1.26,1.26,1.26,1.24,1.21,1.20,1.17,1.14,1.13,1.15,1.18,1.19,1.21,1.23,1.26,1.25,1.26,1.24,1.23,1.23,1.22,1.25,1.24,1.28,1.31,1.34,1.38,1.34,1.39,1.59,1.59,1.71,1.92,2.07,2.37,0.00,0.00,0.00]
cor140416 = [0.00,0.00,0.85,0.91,1.06,1.16,1.18,1.17,1.17,1.16,1.16,1.15,1.14,1.14,1.13,1.13,1.12,1.12,1.11,1.11,1.10,1.09,1.09,1.07,1.08,1.09,1.09,1.09,1.09,1.08,1.07,1.08,1.08,1.09,1.09,1.09,1.07,1.06,1.06,1.02,1.03,1.04,1.04,1.04,1.04,1.03,1.03,1.02,1.00,1.00,1.02,1.03,1.03,1.03,1.03,1.03,1.02,0.99,0.99,1.01,0.95,0.86,0.95,0.93,0.95,0.99,1.01,1.03,1.03,1.03,1.03,1.03,1.03,1.03,1.03,1.03,1.03,1.02,1.01,1.03,1.00,0.97,1.01,0.99,1.02,1.03,1.03,1.03,1.02,1.03,1.03,1.03,1.03,1.03,1.03,1.03,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,1.00,0.98,0.98,0.99,1.03,1.05,1.05,1.06,1.06,1.06,1.06,1.06,1.06,1.06,1.05,1.05,1.06,1.06,1.06,1.06,1.07,1.08,1.08,1.08,1.08,1.08,1.08,1.08,1.08,1.09,1.08,1.08,1.07,1.07,1.07,1.02,0.92,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,1.09,1.09,1.17,1.09,1.09,1.11,1.12,1.15,1.11,1.13,1.12,1.14,1.12,1.13,1.13,1.13,1.15,1.14,1.12,1.12,1.11,1.10,1.10,1.11,1.13,1.14,1.14,1.16,1.17,1.17,1.17,1.19,1.19,1.18,1.21,1.20,1.22,1.20,1.20,1.23,1.23,1.22,1.24,1.24,1.17,1.23,1.26,1.27,1.32,1.34,0.00,0.00,0.00]
cor140606 = [0.00,0.00,0.64,0.80,1.00,1.15,1.18,1.20,1.20,1.20,1.19,1.19,1.18,1.18,1.16,1.15,1.15,1.14,1.13,1.12,1.11,1.10,1.10,1.06,1.07,1.08,1.08,1.08,1.07,1.05,1.06,1.06,1.05,1.07,1.07,1.06,1.04,1.02,1.01,0.97,0.99,1.02,1.02,1.06,1.03,1.01,1.00,1.00,0.98,0.99,1.00,1.01,1.00,1.00,1.00,1.00,0.98,0.95,0.94,0.96,0.88,0.84,0.92,0.88,0.92,0.96,0.97,0.99,0.99,0.99,0.98,0.98,0.98,0.98,0.97,0.97,0.96,0.94,0.91,0.86,0.84,0.92,0.93,0.88,0.88,0.90,0.92,0.93,0.92,0.93,0.92,0.93,0.94,0.95,0.94,0.96,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.94,0.90,0.92,0.88,0.89,0.92,0.92,0.93,0.93,0.93,0.92,0.92,0.92,0.91,0.91,0.91,0.91,0.90,0.90,0.90,0.90,0.91,0.91,0.91,0.91,0.90,0.90,0.90,0.89,0.90,0.88,0.87,0.84,0.82,0.82,0.78,0.68,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.60,0.59,0.59,0.64,0.61,0.59,0.57,0.55,0.55,0.56,0.56,0.56,0.56,0.56,0.56,0.56,0.57,0.55,0.55,0.55,0.54,0.53,0.53,0.54,0.54,0.55,0.55,0.56,0.56,0.57,0.57,0.59,0.59,0.56,0.56,0.57,0.56,0.56,0.57,0.56,0.56,0.55,0.57,0.57,0.54,0.59,0.60,0.56,0.64,0.61,0.00,0.00,0.00]
cor140829 = [0.00,0.00,0.67,0.80,0.92,1.02,1.03,1.07,1.08,1.07,1.06,1.07,1.06,1.06,1.06,1.05,1.05,1.04,1.03,1.02,1.01,1.01,1.01,0.98,0.99,0.99,1.00,1.00,1.00,0.99,0.99,0.99,0.99,1.00,1.00,0.99,0.99,0.99,0.97,0.96,0.99,0.99,0.97,0.98,1.00,0.98,0.97,0.97,0.94,0.95,0.97,0.99,0.98,0.98,0.98,0.98,0.96,0.91,0.92,0.97,0.87,0.74,0.90,0.90,0.91,0.94,0.96,0.97,0.98,0.97,0.97,0.97,0.97,0.97,0.97,0.97,0.97,0.96,0.94,0.92,0.84,0.91,0.95,0.94,1.02,1.00,0.96,0.97,0.96,0.97,0.97,0.97,0.97,0.96,0.96,0.95,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.90,0.86,0.88,0.92,0.98,0.98,0.98,0.99,0.99,0.98,0.98,0.98,0.99,0.98,0.98,0.98,0.99,0.99,0.99,0.99,1.00,1.00,1.01,1.01,1.01,1.01,1.01,1.01,1.00,1.02,1.01,1.01,1.01,1.01,1.01,0.92,0.63,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,1.06,1.02,1.02,1.13,1.15,1.12,1.06,1.05,1.05,1.06,1.08,1.07,1.05,1.05,1.05,1.05,1.06,1.05,1.04,1.04,1.03,1.02,1.02,1.02,1.03,1.04,1.04,1.06,1.07,1.07,1.07,1.08,1.08,1.09,1.09,1.11,1.12,1.13,1.14,1.14,1.16,1.16,1.14,1.19,1.11,1.23,1.21,1.10,1.35,1.22,0.00,0.00,0.00]
outImage = MAKE_ARRAY([800, 250, 10000], TYPE = 2, VALUE = 0) ;Create empty array that is large for memory allocation purposes
outImage = 0 ;Set to zero for memory purposes

;;; PROCESSING ;;;
FOREACH single_flightline, fl_list DO BEGIN ;;; LOOP THROUGH FLIGHTLINES ;;;
  print, 'Starting with ' + single_flightline ;Print which flightline is being processed
  flightline_path = main_path + single_flightline + '\' ; Set path for flightline that is being processed
  cd, flightline_path ;Change Directory to flightline that is being processed
  
  ;;; LOOPING THROUH OTHER IMAGES ;;;
  image_list = file_search('*_Regis') ;Get list of all images in flightline that have been rotated
  FOREACH single_image, image_list DO BEGIN ; Loop through all images for a single flightline
    IF strmatch(single_image,'*.hdr') EQ 0 THEN BEGIN ;If the file being processed isn't a header,text, or GCP file proceed
      ;;; BASIC FILE INFO ;;;
      print, 'Processing: ' + single_image
      ENVI_open_file, single_image, R_FID = fidIn ;Open the file
      ENVI_file_query, fidIn,$ ;Get information about file
        DIMS = raster_dims,$ ;The dimensions of the image
        NB = raster_bands,$ ;Number of bands in image
        BNAMES = raster_band_names,$ ;Band names of image
        NS = raster_samples, $ ;Number of Samples
        NL = raster_lines,$ ;Number of lines
        WL = raster_wl,$ ;Wavelengths of image
        DATA_TYPE = raster_data_type, $ ;File data types
        SNAME = raster_file_name ;contains the full name of the file (including path)
      
      ;;; GET DATA & APPLY CORRECTION ;;; 
      outImage = 0 ;This is for memory purposes
      outImage = MAKE_ARRAY([raster_samples, raster_lines, raster_bands], TYPE = raster_data_type, VALUE = 0) ;Create empty array for output image
      
      ;Find Correction Factor for date
      IF strmatch(single_image,'f130411') EQ 1 THEN BEGIN
        factor = cor130411
      ENDIF
      IF strmatch(single_image,'f130606') EQ 1 THEN BEGIN
        factor = cor130606
      ENDIF
      IF strmatch(single_image,'f131125') EQ 1 THEN BEGIN
        factor = cor131125
      ENDIF
      IF strmatch(single_image,'f140416') EQ 1 THEN BEGIN
        factor = cor140416
      ENDIF
      IF strmatch(single_image,'f140606') EQ 1 THEN BEGIN
        factor = cor140606
      ENDIF
      IF strmatch(single_image,'f140829') EQ 1 THEN BEGIN
        factor = cor140829
      ENDIF
      
      FOR bandNum = 1, 224 DO BEGIN ; loop through bands
        outImage[*,*,bandNum] = ENVI_GET_DATA(DIMS = raster_dims,FID = fidIn,POS = bandNum) ;get the data for a specific band
        outImage[*,*,bandNum] = factor[bandNum]*outImage ; apply correction        
      ENDFOR
      
      ;;; WRITE DATA TO ENVI FILE ;;;
      print, 'Writing: ' + single_image
      fileOutput = raster_file_name + '_Cor' ;Set file name for new image
      ENVI_WRITE_ENVI_FILE, outImage, $ ; Data to write to file
        OUT_NAME = fileOutput, $ ;Output file name
        NB = raster_bands, $; Number of Bands
        NL = raster_lines, $ ;Number of lines
        NS = raster_samples, $ ;Number of Samples
        BNAMES = bandnameList,$ ; Band names assigned to data
        BBL = badbandList,$;array of ones and zeros representing the good and bad bands
        WL = wavelengthList,$;array of wavelength values
        WAVELENGTH_UNITS = 1L ;wavelength units: 0L for micrometers, 1L for nanometers
      
      ;;; CLEANING UP ;;;
      close, fidOut
      close, fidIn
              
     ENDIF ;End of if statement to select image files (not header, text, or GCP files)
  ENDFOREACH ;End of loop through images in a flightline
ENDFOREACH ;End of loop through flightline

END ;END of file