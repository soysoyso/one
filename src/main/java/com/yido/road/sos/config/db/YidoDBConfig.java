package com.yido.road.sos.config.db;
import javax.sql.DataSource;

import org.apache.ibatis.session.SqlSessionFactory;
import org.mybatis.spring.SqlSessionFactoryBean;
import org.mybatis.spring.SqlSessionTemplate;
import org.mybatis.spring.annotation.MapperScan;
import org.mybatis.spring.boot.autoconfigure.SpringBootVFS;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.transaction.annotation.EnableTransactionManagement;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

@Configuration
@MapperScan(basePackages="com.yido.road.sos.repository.yido", sqlSessionFactoryRef="yidoSqlSessionFactory")
@EnableTransactionManagement
public class YidoDBConfig {
    /**
     * hikari config
     */
    @Bean(name="yidoHikariConfig")
    @ConfigurationProperties(prefix = "spring.yido.datasource.hikari")
    public HikariConfig yidoHikariConfig() {
        return new HikariConfig();
    }

    /**
     * datasource
     */
    @Bean(name="yidoDataSource")
    public HikariDataSource yidoDataSource(@Qualifier("yidoHikariConfig") HikariConfig hikariConfig) {
        return new HikariDataSource(hikariConfig);
    }

    /**
     * sqlSessionFactory
     */
	@Primary
    @Bean(name="yidoSqlSessionFactory")
    public SqlSessionFactory yidoSqlSessionFactory(@Qualifier("yidoDataSource") DataSource dataSource, 
    		ApplicationContext applicationContext) throws Exception {
        SqlSessionFactoryBean sqlSessionFactoryBean = new SqlSessionFactoryBean();
        sqlSessionFactoryBean.setDataSource(dataSource);
        sqlSessionFactoryBean.setVfs(SpringBootVFS.class);
        sqlSessionFactoryBean.setConfigLocation(applicationContext.getResource("classpath:mybatis-config.xml"));
        sqlSessionFactoryBean.setMapperLocations(applicationContext.getResources("classpath:/mapper.yido/*.xml"));
        return sqlSessionFactoryBean.getObject();
    }//sqlSessionFactory()
    
    /**
     * sqlSessionTemplate
     */
	@Primary
    @Bean(name="yidoSqlSessionTemplate")
    public SqlSessionTemplate yidoSqlSessionTemplate(@Qualifier("yidoSqlSessionFactory") SqlSessionFactory sqlSessionFactory) {
        return new SqlSessionTemplate(sqlSessionFactory);
    }//sqlSessionTemplate()
	
    /**
     * transaction manager
     */
    @Bean(name= "yidoTxManager")
    public DataSourceTransactionManager yidoTxManager(@Qualifier("yidoDataSource") DataSource dataSource) {
        DataSourceTransactionManager dataSourceTransactionManager = new DataSourceTransactionManager(dataSource);
        dataSourceTransactionManager.setNestedTransactionAllowed(true); // nested

        return dataSourceTransactionManager;
    }
}// end class
