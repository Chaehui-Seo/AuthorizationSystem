# Authorization System

<div align="center">
![Swift](https://img.shields.io/badge/swift-v5.5.2-orange?logo=swift) ![Xcode](https://img.shields.io/badge/xcode-v13.1-blue?logo=xcode) ![nodejs](https://img.shields.io/badge/node.js-v16.13.1-green?logo=node.js) ![mySQL](https://img.shields.io/badge/mySQL-v8.0.23-black?logo=mysql&logoColor=white)
</div align="center">
</br>

## About Project
Node.js로 서버를 구축하고 Amazon RDS로 MySQL을 운영하고 있는 iOS 앱입니다.
인증 시스템을 주요하게 다루되, 앱단에서 보여줄 수 있는 요소들을 자유롭개 추가하였습니다.

</br>
## ScreenShots
<Blockquote>
실제 앱 구동화면입니다
</Blockquote>

| ![](./image/register.gif) | ![](./image/userLogin.gif) | ![](./image/admin.gif) | ![](./image/autoLogin.gif) |
| :-: | :-: | :-: | :-: |
| 회원가입 페이지 | 일반유저 로그인 | 관리자 로그인 | 자동 로그인 |
| ![](./image/blockedUser.gif) | ![](./image/addMemo.gif) | ![](./image/editAccount.gif) | ![](./image/tapGesture.gif) |
| 차단유저 로그인  | 개인 메모 작성 | 개인정보 수정 | 탭제스처 인식 |
</br>
##Installation
<Blockquote>
Server 폴더에 아래 사항들을 추가하신 후 npm start를 실행해주시기 바랍니다.
(테스트 run을 위해서 해당 정보가 필요하신 경우 말씀해주시면 제공해드리겠습니다.)
</Blockquote>
```sh
PORT=3306
dbHost= Your DB Host URL
dbUser= Your DB Master UserName
dbPassword= Your DB Master Password
dbName= Your DB Master Name
emailId= Your Email Address For SMTP
emailPw= Your Email Password For SMTP
jwtSecret= Your Secret Key
```
</br>
## Features
### 이메일 인증을 통한 회원가입
- SMTP를 사용하여 이메일 인증 구현

### 보다 안전한 토큰 기반 인증
- Refresh Token과 AccessToken를 둘다 이용하여서 보안 강화

### 자동로그인
- SwiftKeychainWrapper와 UserDefaults를 사용해서 자동로그인 구현

### 애니메이션 요소
- Lottie와 CGAffineTransform를 이용하여서 디테일한 애니메이션 추가

### User Interactive 요소 가미
- 유저의 long press와 tap 동작에 상호작용적으로 반응하는 UX 요소 추가
</br>
## Architecture
### 전체 아키텍처
 <Blockquote>
모놀리식 아키텍처를 사용하였습니다.
</Blockquote>
![](./image/architecture.png)

### iOS 구조
<Blockquote>
MVVM 패턴을 채택하였습니다. 화면 간의 연결은 아래와 같이 구성되었습니다.
</Blockquote>
![](./image/iOS_Structure.png)

</br>
## Technical Achievements
### 서버 사이드
- 직접 RDBMS를 설계하고, SQL 쿼리문을 작성하였다.
- 토큰을 이용한 인증 절차를 이해하고, access token과 refresh token을 도입하였다. access token은 2시간, refresh token은 14일 후 만료되도록 설정하였습니다.
- SMTP를 사용하여서 이메일 인증을 구현하였다.
- node.js로 서버를 구축하고 restAPI를 설계 및 구현하였다.

### iOS 사이드
- Refresh token과 access token을 관리하고, 서버와 통신하며 적절한 액션을 취하도록 구현하였다.
- 여러 계층에 거친 데이터 전달과 비동기 이벤트 핸들링을 위해서 Combine을 적극 사용하였다.
- SwiftKeychainWrapper와 UserDefaults를 적절히 활용하여 자동로그인을 구현하였다.
- 회원가입을 진행하던 중 예상치 못하게 종료에 대응할 수 있도록 UserDefaults를 이용하였다.
- Lottie와 CGAffineTransform를 이용하여서 애니메이션적인 요소를 추가하여 앱의 완성도를 높였다.
- 유저의 제스처에 반응하여서 애니메이션의 위치가 바뀌거나, long press로 반응 이모지를 보내는 등 interactive한 재미 요소들을 추가하였다.
