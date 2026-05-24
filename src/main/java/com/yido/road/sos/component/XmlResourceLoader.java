package com.yido.road.sos.component;

import java.io.InputStream;
import java.util.*;

public class XmlResourceLoader {

    public static ResourceBundle load(String baseName, Locale locale) {
        return ResourceBundle.getBundle(baseName, locale, new XMLResourceBundleControl());
    }

    /**
     * XML 형식 리소스를 처리하는 커스텀 ResourceBundle.Control
     */
    private static class XMLResourceBundleControl extends ResourceBundle.Control {

        @Override
        public List<String> getFormats(String baseName) {
            return Collections.singletonList("xml");
        }

        @Override
        public ResourceBundle newBundle(String baseName, Locale locale, String format,
                                        ClassLoader loader, boolean reload)
                throws IllegalAccessException, InstantiationException {

            if (!"xml".equals(format)) {
                throw new IllegalArgumentException("unknown format: " + format);
            }

            String bundleName = toBundleName(baseName, locale); // e.g. messages.voc_en
            String resourceName = toResourceName(bundleName, format); // e.g. messages/voc_en.xml

            try (InputStream stream = loader.getResourceAsStream(resourceName)) {
                if (stream == null) return null;
                return new XMLResourceBundle(stream);
            } catch (Exception e) {
                throw new RuntimeException("Failed to load XML bundle: " + resourceName, e);
            }
        }
    }

    /**
     * XML 파일을 읽어들여 Map 기반 리소스 번들로 만드는 클래스
     */
    private static class XMLResourceBundle extends ResourceBundle {
        private final Properties props;

        XMLResourceBundle(InputStream stream) throws Exception {
            props = new Properties();
            props.loadFromXML(stream); // ← XML 형식 파일 읽기
        }

        @Override
        protected Object handleGetObject(String key) {
            return props.getProperty(key);
        }

        @Override
        public Enumeration<String> getKeys() {
            return Collections.enumeration(props.stringPropertyNames());
        }
    }
}
