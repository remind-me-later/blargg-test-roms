; The sources use features of RGBDS 1.0 (the `>>>` operator, `LOAD UNION`,
; `MACRO?`...), and have been tested with 1.0.4.

IF !DEF(__RGBDS_MAJOR__) || __RGBDS_MAJOR__ < 1
	FATAL "These sources need RGBDS 1.0 or later"
ENDC
