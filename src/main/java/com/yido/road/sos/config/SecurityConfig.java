package com.yido.road.sos.config;

import com.yido.road.sos.security.CommonAuthenticationFailureHandler;
import com.yido.road.sos.security.CustomLogoutSuccessHandler;
import com.yido.road.sos.security.MyAuthenticationSuccessHandler;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.builders.WebSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.authentication.LoginUrlAuthenticationEntryPoint;
import org.springframework.security.web.util.matcher.AntPathRequestMatcher;

@Configuration
@EnableMethodSecurity(prePostEnabled = true)
@EnableWebSecurity
public class SecurityConfig extends WebSecurityConfigurerAdapter {

    private final UserDetailsService userDetailsService;
    private final PasswordEncoder passwordEncoder;
    private final MyAuthenticationSuccessHandler successHandler;
    private final CommonAuthenticationFailureHandler failureHandler;
    private final CustomLogoutSuccessHandler logoutSuccessHandler;

    public SecurityConfig(
            @Qualifier("commonUserDetailsService") UserDetailsService userDetailsService,
            PasswordEncoder passwordEncoder,
            MyAuthenticationSuccessHandler successHandler,
            CommonAuthenticationFailureHandler failureHandler,
            CustomLogoutSuccessHandler logoutSuccessHandler
    ) {
        this.userDetailsService = userDetailsService;
        this.passwordEncoder = passwordEncoder;
        this.successHandler = successHandler;
        this.failureHandler = failureHandler;
        this.logoutSuccessHandler = logoutSuccessHandler;
    }

    /**
     * 정적 리소스는 Security 제외
     */
    @Override
    public void configure(WebSecurity web) {
        web.ignoring().antMatchers("/css/**","/js/**","/img/**" );
    }

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http
                .headers().frameOptions().sameOrigin()
                .and()
                .authorizeRequests()

                // ====== PUBLIC ======
                .antMatchers(
                        "/",
                        "/admin/login", "/admin/login-error",
                        "/manage/login", "/manage/login-error",
                        "/auth/checkLogin",
                        "/logout",
                        "/api/**", "/pdf/**",
                        "/sos/**",
                        "/pothole/img/**"
                ).permitAll()

                // ✅ admin 엔트리포인트는 "로그인만" 되어있으면 통과시킨다
                .antMatchers("/admin", "/admin/", "/admin/main").authenticated()

                // ====== ADMIN (IMS 포함) ======
                .antMatchers("/admin/ims/**").hasAnyAuthority("ATH100", "ATH200")
                .antMatchers("/admin/**").hasAnyAuthority("ATH100", "ATH200", "ATH400")

                // ====== MANAGE (오케이로드) ======
                .antMatchers("/manage/**", "/pothole/**", "/ims/**").hasAuthority("ATH300")

                .anyRequest().permitAll()
                .and()

                .exceptionHandling()
                .defaultAuthenticationEntryPointFor(
                        new LoginUrlAuthenticationEntryPoint("/admin/login"),
                        new AntPathRequestMatcher("/admin/**")
                )
                .defaultAuthenticationEntryPointFor(
                        new LoginUrlAuthenticationEntryPoint("/manage/login"),
                        new AntPathRequestMatcher("/manage/**")
                )
                .and()

                .formLogin()
                .loginPage("/manage/login")
                .loginProcessingUrl("/auth/checkLogin")
                .usernameParameter("userId")
                .passwordParameter("userPwd")
                .successHandler(successHandler)
                .failureHandler(failureHandler)
                .permitAll()
                .and()

                .rememberMe()
                .key("rsos")
                .rememberMeParameter("rememberMe")
                .tokenValiditySeconds(86400 * 30)
                .userDetailsService(userDetailsService)
                .and()

                .logout()
                .logoutUrl("/logout")
                .logoutSuccessHandler(logoutSuccessHandler)
                .invalidateHttpSession(true)
                .deleteCookies("JSESSIONID", "remember-me")
                .permitAll()
                .and()

                .csrf().disable();
    }


    /**
     * 인증 처리
     */
    @Override
    protected void configure(AuthenticationManagerBuilder auth) throws Exception {
        auth.userDetailsService(userDetailsService)
                .passwordEncoder(passwordEncoder);
    }
}
