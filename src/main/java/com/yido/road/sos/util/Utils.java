package com.yido.road.sos.util;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.lang.reflect.Field;
import java.net.HttpURLConnection;
import java.net.InetAddress;
import java.net.URL;
import java.net.URLEncoder;
import java.net.UnknownHostException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.yido.road.sos.model.PotholeImage;
import org.json.JSONObject;
import org.springframework.core.io.ClassPathResource;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartHttpServletRequest;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import lombok.extern.slf4j.Slf4j;

@Slf4j
public class Utils {


    public static String getParam(Map<String, Object> params, String key) {
        Object value = params.get(key);
        return value != null ? value.toString().trim() : "";
    }
	 public static void sendData(HttpServletResponse response, Object data) {
    	try {
    		response.setCharacterEncoding("UTF-8");
        	response.setContentType("text/html; charset=UTF-8");

        	PrintWriter out = response.getWriter();

            out.print(data);
            out.flush();
            out.close();

            log.debug(String.format("[SendData] %s", data.toString()));
    	} catch(Exception e) {
    		e.printStackTrace();
    	}
    }

    public static void sendData(HttpServletResponse response, Object data, boolean logYn) {
    	try {
    		response.setCharacterEncoding("UTF-8");
        	response.setContentType("text/html; charset=UTF-8");

        	PrintWriter out = response.getWriter();

            out.print(data);
            out.flush();
            out.close();

            if(logYn) {
            	log.debug(String.format("[SendData] %s", data.toString()));
            } else {
            	log.debug(String.format("[SendData] %s", "데이터가 길어서 로그 제외"));
            }
    	} catch(Exception e) {
    		e.printStackTrace();
    	}
    }

    public static String makeJsonString(ResultVO result) {
    	String returnValue = "{ \"resultCode\" : \"%s\", \"resultMessage\" : \"%s\", \"rows\" : %s, \"subData\" : %s }";
    	String mainData = "\"\"";
    	String subData = "\"\"";

    	Gson gson = new GsonBuilder().serializeNulls().create();

    	if(result.getData() != null) {
    		mainData = gson.toJson(result.getData());
    	}

    	if(result.getSub() != null) {
    		subData = gson.toJson(result.getSub());
    	}

		returnValue = String.format(returnValue, result.getCode(), result.getMessage(), mainData, subData);

    	return returnValue;
    }

    public static String makeJsonString(List<Map<String, Object>> data) {
    	String rValue = "";

    	Gson gson = new GsonBuilder().serializeNulls().create();

    	if(data != null) {
    		rValue = gson.toJson(data);
    	}

    	return rValue;
    }

    public static String getJsonValue(JSONObject obj, String key){
    	return obj.get(key) == null ? "" : obj.get(key).toString();
    }

    public static String getLocalIpAddr() {
    	String returnValue = "";
    	InetAddress local;
		try {
		    local = InetAddress.getLocalHost();
		    returnValue = local.getHostAddress();
		} catch (UnknownHostException e1) {
		    e1.printStackTrace();
		}

		return returnValue;
    }

    public static String getProperties(String key, String defaultValue) {
    	String returnValue = null;

        try{

            String propFile = new ClassPathResource("application.properties").getURI().getPath();

            Properties props = new Properties();

            FileInputStream fis = new FileInputStream(propFile);

            props.load(new java.io.BufferedInputStream(fis));

            returnValue = props.getProperty(key) ;
        }catch(Exception e){
            e.printStackTrace();
        }

        return returnValue == null ? defaultValue : returnValue.replace(" ", "");
    }

    public static String getPropertiesByType(String key, String defaultValue, String type) {
    	String returnValue = null;

        try{

        	String propFile = "";

        	if (type.equals("develop")) propFile = new ClassPathResource("application-develop.properties").getURI().getPath();
        	else if (type.equals("production")) propFile = new ClassPathResource("application-production.properties").getURI().getPath();
            Properties props = new Properties();

            FileInputStream fis = new FileInputStream(propFile);

            props.load(new java.io.BufferedInputStream(fis));

            returnValue = props.getProperty(key) ;
        }catch(Exception e){
            e.printStackTrace();
        }

        return returnValue == null ? defaultValue : returnValue.replace(" ", "") ;
    }

	public static String getWeekType(String bkDate) throws ParseException {
		 String weekType = "" ;

		SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd") ;
		java.util.Date nDate = dateFormat.parse(bkDate);
		Calendar cal = Calendar.getInstance();
		cal.setTime(nDate);
		int dayNum = cal.get(Calendar.DAY_OF_WEEK);

		switch(dayNum){
			case 1:
				weekType = "2"; //"일";
				break ;
			case 2:
				weekType = "1"; //"월";
				break ;
			case 3:
				weekType = "1"; //"화";
				break ;
			case 4:
				weekType = "1"; //"수";
				break ;
			case 5:
				weekType = "1"; //"목";
				break ;
			case 6:
				weekType = "1"; //"금";
				break ;
			case 7:
				weekType = "2"; //"토";
				break ;
		}

		return weekType;

	}

    public static String getExtension(String fileName) {
    	String returnValue = "";

    	try {
    		returnValue = fileName.substring(fileName.lastIndexOf(".") + 1);
    	} catch (Exception e) {
    		e.printStackTrace();
    	}

    	return returnValue;
    }

    public static String convertSpecialCharacters(String content) {
    	String returnValue = content;

		returnValue = returnValue.replaceAll("&", "&amp;");
		returnValue = returnValue.replaceAll("<", "&lt;");
		returnValue = returnValue.replaceAll(">", "&gt;");
		returnValue = returnValue.replaceAll("\"", "&quot;");

    	return returnValue;
    }

    /**
     * Disposition 지정하기
     * @param filename
     * @param request
     * @param response
     * @throws Exception
     */
    public static void setDisposition(String filename, HttpServletRequest request, HttpServletResponse response) throws Exception {
        String browser = getBrowser(request);

        String dispositionPrefix = "attachment; filename=";
        String encodedFilename = null;

        if (browser.equals("MSIE")) {
            encodedFilename = URLEncoder.encode(filename, "UTF-8").replaceAll("\\+", "%20");
        } else if (browser.equals("Trident")) { // IE11 문자열 깨짐 방지
            encodedFilename = URLEncoder.encode(filename, "UTF-8").replaceAll("\\+", "%20");
        } else if (browser.equals("Firefox")) {
            encodedFilename = "\"" + new String(filename.getBytes("UTF-8"), "8859_1") + "\"";
        } else if (browser.equals("Opera")) {
            encodedFilename = "\"" + new String(filename.getBytes("UTF-8"), "8859_1") + "\"";
        } else if (browser.equals("Chrome")) {
            StringBuffer sb = new StringBuffer();
            for (int i = 0; i < filename.length(); i++) {
                char c = filename.charAt(i);
                if (c > '~') {
                    sb.append(URLEncoder.encode("" + c, "UTF-8"));
                } else {
                    sb.append(c);
                }
            }
            encodedFilename = sb.toString();
        } else {
            throw new IOException("Not supported browser");
        }

        response.setHeader("Content-Disposition", dispositionPrefix + encodedFilename);

        if ("Opera".equals(browser)) {
            response.setContentType("application/octet-stream;charset=UTF-8");
        }
    }

    /**
     * 브라우저 구분 얻기
     * @param request
     * @return
     */
    public static String getBrowser(HttpServletRequest request) {
        String header = request.getHeader("User-Agent");
        if (header.indexOf("MSIE") > -1) {
            return "MSIE";
        } else if (header.indexOf("Trident") > -1) { // IE11 문자열 깨짐 방지
            return "Trident";
        } else if (header.indexOf("Chrome") > -1) {
            return "Chrome";
        } else if (header.indexOf("Opera") > -1) {
            return "Opera";
        }
        return "Firefox";
    }

    public static String getClientIpAddress(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");

        if (ip == null) {
            ip = request.getHeader("Proxy-Client-IP");
        }
        if (ip == null) {
            ip = request.getHeader("WL-Proxy-Client-IP");
        }
        if (ip == null) {
            ip = request.getHeader("HTTP_CLIENT_IP");
        }
        if (ip == null) {
            ip = request.getHeader("HTTP_X_FORWARDED_FOR");
        }
        if (ip == null) {
            ip = request.getRemoteAddr();
        }

        return ip;
    }

    public static String getClientIpAddress(MultipartHttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");

        if (ip == null) {
            ip = request.getHeader("Proxy-Client-IP");
        }
        if (ip == null) {
            ip = request.getHeader("WL-Proxy-Client-IP");
        }
        if (ip == null) {
            ip = request.getHeader("HTTP_CLIENT_IP");
        }
        if (ip == null) {
            ip = request.getHeader("HTTP_X_FORWARDED_FOR");
        }
        if (ip == null) {
            ip = request.getRemoteAddr();
        }

        return ip;
    }

    public static String getCurrentDate(String format) {
    	return new SimpleDateFormat(format).format(new Date());
    }

    public static int getDiffOfDate(String begin, String end) {
    	int returnValue = 0;

    	try {
    		 SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMdd");

    	      Date beginDate = formatter.parse(begin);
    	      Date endDate = formatter.parse(end);

    	      long diff = endDate.getTime() - beginDate.getTime();
    	      returnValue = (int) (diff / (24 * 60 * 60 * 1000));
    	} catch(Exception e) {
    		e.printStackTrace();
    	}

      return returnValue;
    }

    /**
     * 날짜 형식 변경 함수
     *
     * @param sDate => "20230510"
     * @param separator => "-"
     * @return => 2023-05-10
     */
    public static String getDateFormat(String sDate, String separator) {
    	String returnValue = "";

    	if (sDate != null && sDate.length() == 8) {
    		returnValue = sDate.substring(0, 4) + separator
    				+ sDate.substring(4 ,6) + separator
    				+ sDate.substring(6, 8);
    	}

    	return returnValue;
    }

    /**
	 * 날짜 정규표현식 체크
	 *
	 * @param date 입력일자
	 * @param format 포맷팅
	 * @return boolean
	 */
	public static boolean isDate(String date, String format) {
		boolean ret = true;
		boolean chkDateTime = false;
		boolean chkTime = false;
		String pattern = "";
		DateTimeFormatter formatter = DateTimeFormatter.BASIC_ISO_DATE;

		if(format == null || format.equals(""))
			return false;

		switch(format) {
		case "yyyyMMdd":
			pattern = "(19|20)\\d{2}(0[1-9]|1[012])(0[1-9]|[12][0-9]|3[01])";
			formatter = DateTimeFormatter.BASIC_ISO_DATE;
			break;
		case "yyyy-MM-dd":
			pattern = "(19|20)\\d{2}\\-(0[1-9]|1[012])\\-(0[1-9]|[12][0-9]|3[01])";
			formatter = DateTimeFormatter.ISO_DATE;
			break;
		case "yyyy-MM-dd HH:mm:ss":
			pattern = "(19|20)\\d{2}\\-(0[1-9]|1[012])\\-(0[1-9]|[12][0-9]|3[01]) ([0-1][0-9]|2[0-3]):([0-5][0-9]):([0-5][0-9])";
			formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
			chkDateTime = true;
			break;
		case "HH:mm":
			pattern = "([0-1][0-9]|2[0-3]):([0-5][0-9])";
			formatter = DateTimeFormatter.ofPattern("HH:mm");
			chkTime = true;
			break;
		case "HH:mm:ss":
			pattern = "([0-1][0-9]|2[0-3]):([0-5][0-9]):([0-5][0-9])";
			formatter = DateTimeFormatter.ofPattern("HH:mm:ss");
			chkTime = true;
			break;
		}

		ret = date.matches(pattern);

		//log.debug("ret: {}",ret);

		try {
			if(chkDateTime) {
				LocalDateTime.parse(date, formatter);
				//log.debug("fmtDateTime====>"+LocalDateTime.parse(date, formatter));
			} else if(chkTime)  {
				LocalTime.parse(date, formatter);
				//log.debug("fmtTime====>"+LocalTime.parse(date, formatter));
			} else {
				LocalDate.parse(date, formatter);
				//log.debug("fmtDate====>"+LocalDate.parse(date, formatter));
			}
		} catch(Exception e) {
			e.printStackTrace();
			log.error("isDate ERROR!!!");

			ret = false;
		}

		return ret;
	}//isDate()

	/* 휴대폰번호 정규표현식 체크 */
	public static boolean isMobilePhoneNumber(String date) {
		boolean ret = false;
		String pattern = "^01(?:0|1|[6-9])-(\\d{3}|\\d{4})-(\\d{4})$";

		ret = date.matches(pattern);

		return ret;
	}//isMobilePhoneNumber()

    // VO -> Map
    public static Map<String, Object> convertVotoMap (Object vo) {
    	ObjectMapper objectMapper = new ObjectMapper();
    	Map<String, Object> map = objectMapper.convertValue(vo, Map.class);
    	return map;
    }


    // Map -> VO
    public static <T> T convertMaptoVo(Map<String, Object> map, Class<T> type) {
        try {
            if (Objects.isNull(type)) {
                throw new NullPointerException("Class cannot be null");
            }
            if (Objects.isNull(map) || map.isEmpty()) {
                throw new IllegalArgumentException("map is null or empty");
            }

            T instance = type.getConstructor().newInstance();
            Field[] fields = type.getDeclaredFields();

            for (Map.Entry<String, Object> entry : map.entrySet()) {
                for (Field field : fields) {
                    if (entry.getKey().equals(field.getName())) {
                        field.setAccessible(true);

                        Object value = Objects.isNull(entry.getValue()) && field.getType().isPrimitive()
                                ? getDefaultValue(field.getType())
                                : map.get(field.getName());

                        field.set(instance, value);
                        break;
                    }
                }
            }
            return instance;
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    private static Object getDefaultValue(Class<?> type) {
        switch (type.getName()) {
            case "byte": case "short": case "int": return 0;
            case "long"    : return 0L;
            case "float"   : return 0.0f;
            case "double"  : return 0.0d;
            case "char"    : return '\u0000';
            case "boolean" : return false;
        }
        return null;
    }

    public static String getUserAgent(HttpServletRequest req) {
    	String ua = null;

		ua = req.getHeader("user-agent");

		if (ua.indexOf("Android") != -1) {
			ua = "Android";
		} else if( ua.indexOf("iPad") != -1 || ua.indexOf("iPhone") != -1 || ua.indexOf("iOS") != -1 || ua.indexOf("MAC") != -1 ) {
			ua = "iPhone";
		} else if( ua.indexOf("Windows") != -1) {
			ua = "Windows";
		} else {
			ua = "";
		}

    	return ua;
    }

    public static String getMsLoginCd(HttpServletRequest req) {
    	String ua = null;

		ua = req.getHeader("user-agent");

		if (ua.indexOf("Android") != -1) {
			ua = "APP";
		} else if( ua.indexOf("iPad") != -1 || ua.indexOf("iPhone") != -1 || ua.indexOf("iOS") != -1 || ua.indexOf("MAC") != -1 ) {
			ua = "APP";
		} else if( ua.indexOf("Windows") != -1) {
			ua = "HOMEPAGE";
		} else {
			ua = "";
		}

    	return ua;
    }

	public static String getYymm() {
		Date now = new Date();
		SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyMM");
		String formattedNow = simpleDateFormat.format(now);
		return formattedNow;
	}

	/**
	 * 서버 통신 메소드
	 * @param apiURL
	 * @param headerStr
	 * @return
	 * @throws IOException
	 */
	public static String requestToServer(String apiURL, String headerStr) throws IOException {
		URL url = new URL(apiURL);
		HttpURLConnection con = (HttpURLConnection)url.openConnection();
		con.setRequestMethod("GET");
		System.out.println("header Str: " + headerStr);

		if(headerStr != null && !headerStr.equals("") ) {
		  con.setRequestProperty("Authorization", headerStr);
		}

		int responseCode = con.getResponseCode();
		BufferedReader br;
		System.out.println("responseCode="+responseCode);

		if(responseCode == 200) { // 정상 호출
			br = new BufferedReader(new InputStreamReader(con.getInputStream()));
		} else {  // 에러 발생
			br = new BufferedReader(new InputStreamReader(con.getErrorStream()));
		}

		String inputLine;
		StringBuffer res = new StringBuffer();

	    while ((inputLine = br.readLine()) != null) {
	    	res.append(inputLine);
	    }
	    br.close();
	    if(responseCode==200) {
	    	return res.toString();
	    } else {
	    	return null;
	    }
	}

    public static PotholeImage findBySortOrd(List<PotholeImage> list, Integer sortOrd) {
        if (list == null || sortOrd == null) return null;

        for (PotholeImage p : list) {
            if (p == null) continue;

            Integer ord = p.getSortOrd();
            if (ord != null && ord.intValue() == sortOrd.intValue()) {
                return p;
            }
        }
        return null;
    }


	public static String ptyToSummary(Integer pty) {
		if (pty == null) return "확인불가";

		switch (pty.intValue()) {
			case 0: return "없음";
			case 1: return "비";
			case 2: return "비/눈";
			case 3: return "눈";
			case 5: return "빗방울";
			case 6: return "빗방울/눈날림";
			case 7: return "눈날림";
			default: return "확인불가";
		}
	}

	public static String skyToCode(Integer sky) {
		if (sky == null) return "default";

		switch (sky.intValue()) {
			case 1: return "001"; // 맑음
			case 2: return "002"; // 구름조금(사용하면)
			case 3: return "003"; // 구름많음
			case 4: return "004"; // 흐림
			default: return "default";
		}
	}

	/**
	 * 최종 저장용 weatherCd (공통코드 007)
	 */
	public static String toWeatherCd(Integer pty, Integer sky) {

		// ✅ 강수 우선
		if (pty != null && pty.intValue() != 0) {
			switch (pty.intValue()) {
				case 1: return "W005"; // 비
				case 2: return "W007"; // 비/눈
				case 3: return "W006"; // 눈
				case 5: return "W008"; // 빗방울
				case 6: return "W007"; // 빗방울/눈날림
				case 7: return "W009"; // 눈날림
				default: return "W999"; // 확인불가
			}
		}

		// ✅ 강수 없으면 SKY
		if (sky == null) return "W999";

		switch (sky.intValue()) {
			case 1: return "W001"; // 맑음
			case 2: return "W002"; // 구름조금
			case 3: return "W003"; // 구름많음
			case 4: return "W004"; // 흐림
			default: return "W999";
		}
	}

	public static String toWeatherText(Integer pty, Integer sky) {

		if (pty != null && pty.intValue() != 0) {
			switch (pty.intValue()) {
				case 1: return "비";
				case 2: return "비/눈";
				case 3: return "눈";
				case 5: return "빗방울";
				case 6: return "빗방울/눈날림";
				case 7: return "눈날림";
				default: return "확인불가";
			}
		}

		if (sky == null) return "확인불가";
		switch (sky.intValue()) {
			case 1: return "맑음";
			case 2: return "구름조금";
			case 3: return "구름많음";
			case 4: return "흐림";
			default: return "확인불가";
		}
	}


	public static String toWeatherIcon(Integer pty, Integer sky, String skyCode) {

		// 1) 강수 우선
		if (pty != null && pty.intValue() != 0) {
			switch (pty.intValue()) {
				case 1: return "🌧️"; // 비
				case 2: return "🌨️"; // 비/눈
				case 3: return "❄️";  // 눈
				case 5: return "🌧️"; // 빗방울
				case 6: return "🌨️"; // 빗방울/눈날림
				case 7: return "❄️";  // 눈날림
				default: return "-";
			}
		}

		// 2) 하늘 상태
		if (skyCode == null) return "-";

		if ("001".equals(skyCode)) return "☀️";
		if ("002".equals(skyCode)) return "🌤️";
		if ("003".equals(skyCode)) return "⛅";
		if ("004".equals(skyCode)) return "☁️";

		return "-";
	}
	public static String getSafeExt(String originalName, String contentType) {
		String lower = originalName == null ? "" : originalName.toLowerCase();
		if (lower.endsWith(".jpg") || lower.endsWith(".jpeg")) return ".jpg";
		if (lower.endsWith(".png")) return ".png";
		if (lower.endsWith(".webp")) return ".webp";
		if ("image/png".equals(contentType)) return ".png";
		if ("image/webp".equals(contentType)) return ".webp";
		return ".jpg";
	}

	public static List<Integer> parseCsvInt(String csv) {
		if (!StringUtils.hasText(csv)) return Collections.emptyList();
		String[] arr = csv.split(",");
		List<Integer> list = new ArrayList<>();
		for (int i = 0; i < arr.length; i++) {
			String s = arr[i] == null ? "" : arr[i].trim();
			if (s.isEmpty()) continue;
			try { list.add(Integer.parseInt(s)); } catch (Exception ignore) {}
		}
		return list;
	}


	public static List<String> parseSiteCdList(String rawSiteCdList) {
		List<String> result = new ArrayList<>();

		if (rawSiteCdList == null || rawSiteCdList.trim().isEmpty()) {
			return result;
		}

		String[] arr = rawSiteCdList.split(",");
		for (String s : arr) {
			if (s != null && !s.trim().isEmpty()) {
				result.add(s.trim());
			}
		}

		return result;
	}


	/** null-safe trim */
	public static String safeTrim(String s) {
		return s == null ? "" : s.trim();
	}

	/** null-safe string */
	public static String safe(String s) {
		return s == null ? "" : s;
	}

	public static String safeStr(Object v) {
		return v == null ? "" : String.valueOf(v).trim();
	}

	public static Integer toInt(Object v) {
		try {
			if (v == null) return null;
			return Integer.parseInt(String.valueOf(v));
		} catch (Exception e) {
			return null;
		}
	}

}// end class
