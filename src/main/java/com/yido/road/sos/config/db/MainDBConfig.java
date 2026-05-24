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
@MapperScan(basePackages={"com.yido.road.sos.repository.main"}, sqlSessionFactoryRef="mainSqlSessionFactory")
@EnableTransactionManagement
public class MainDBConfig {
    /**
     * hikari config
     */
	@Primary
    @Bean(name="mainHikariConfig")
    @ConfigurationProperties(prefix = "spring.main.datasource.hikari")
    public HikariConfig mainHikariConfig() {
        return new HikariConfig();
    }

    /**
     * datasource
     */
	@Primary
    @Bean(name="mainDataSource")
    public HikariDataSource mainDataSource(@Qualifier("mainHikariConfig") HikariConfig hikariConfig) {
        return new HikariDataSource(hikariConfig);
    }

    /**
     * sqlSessionFactory
     */
	@Primary
    @Bean(name="mainSqlSessionFactory")
    public SqlSessionFactory mainSqlSessionFactory(@Qualifier("mainDataSource") DataSource dataSource, 
    		ApplicationContext applicationContext) throws Exception {
        SqlSessionFactoryBean sqlSessionFactoryBean = new SqlSessionFactoryBean();
        sqlSessionFactoryBean.setDataSource(dataSource);
        sqlSessionFactoryBean.setVfs(SpringBootVFS.class);
        sqlSessionFactoryBean.setConfigLocation(applicationContext.getResource("classpath:mybatis-config.xml"));
        sqlSessionFactoryBean.setMapperLocations(applicationContext.getResources("classpath:/mapper.main/*.xml"));
        return sqlSessionFactoryBean.getObject();
    }//sqlSessionFactory()
    
    /**
     * sqlSessionTemplate
     */
	@Primary
    @Bean(name="mainSqlSessionTemplate")
    public SqlSessionTemplate mainSqlSessionTemplate(@Qualifier("mainSqlSessionFactory") SqlSessionFactory sqlSessionFactory) {
        return new SqlSessionTemplate(sqlSessionFactory);
    }//sqlSessionTemplate()
	
    /**
     * transaction manager
     */
	@Primary
    @Bean(name= "mainTxManager")
    public DataSourceTransactionManager mainTxManager(@Qualifier("mainDataSource") DataSource dataSource) {
        DataSourceTransactionManager dataSourceTransactionManager = new DataSourceTransactionManager(dataSource);
        dataSourceTransactionManager.setNestedTransactionAllowed(true); // nested

        return dataSourceTransactionManager;
    }
}// end class
