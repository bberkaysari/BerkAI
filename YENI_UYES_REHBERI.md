# BerkAI Projesine Kişi Ekleme Rehberi

## 🎯 Projeye Yeni Bir Kişi Nasıl Dahil Edilir?

Bu rehber, BerkAI projesine yeni bir ekip üyesi veya katkıda bulunan kişi ekleme sürecini adım adım açıklar.

## 📋 Ön Hazırlık

### 1. GitHub Repository Erişimi (Proje Sahibi İçin)

Eğer birini doğrudan projenize eklemek istiyorsanız:

1. **GitHub repository sayfanıza** gidin: https://github.com/bberkaysari/BerkAI
2. **Settings** (Ayarlar) sekmesine tıklayın
3. Sol menüden **Collaborators** (İşbirlikçiler) seçin
4. **Add people** (Kişi ekle) butonuna tıklayın
5. Eklemek istediğiniz kişinin **GitHub kullanıcı adını** veya **e-posta adresini** girin
6. Uygun **yetki seviyesini** seçin:
   - **Read**: Sadece okuma (kod görüntüleme)
   - **Write**: Yazma yetkisi (kod değişikliği yapabilir)
   - **Admin**: Yönetici (tam yetki)
7. **Add [kullanıcı adı] to this repository** butonuna tıklayın

### 2. Davet Etme (Katkıda Bulunanlar İçin)

Birini fork ve pull request yöntemiyle katkıda bulunmaya davet etmek için:

1. Kişiye **repository URL'ini** gönderin: https://github.com/bberkaysari/BerkAI
2. **[CONTRIBUTING.md](./CONTRIBUTING.md)** dosyasını okumasını isteyin
3. **[README.md](./README.md)** dosyasındaki kurulum adımlarını takip etmesini söyleyin

## 🚀 Yeni Ekip Üyesi İçin Kurulum Adımları

### Adım 1: Gerekli Yazılımları Yükleyin

#### Backend için:
- [.NET 9 SDK](https://dotnet.microsoft.com/download/dotnet/9.0) indirin ve kurun
- [SQL Server](https://www.microsoft.com/sql-server) veya [PostgreSQL](https://www.postgresql.org/) yükleyin

#### Frontend için:
- [Node.js](https://nodejs.org/) v18 veya üstü sürümünü yükleyin
- npm otomatik olarak Node.js ile gelir

#### Geliştirme Araçları:
- [Visual Studio Code](https://code.visualstudio.com/) (Önerilen)
- [Visual Studio 2022](https://visualstudio.microsoft.com/) (Backend için opsiyonel)
- [Git](https://git-scm.com/) (versiyon kontrolü için)

### Adım 2: Projeyi Klonlayın

#### Doğrudan Erişim (Collaborator iseniz):
```bash
git clone https://github.com/bberkaysari/BerkAI.git
cd BerkAI
```

#### Fork Yöntemi (Dış Katkıda Bulunanlar İçin):
1. GitHub'da projeye gidin: https://github.com/bberkaysari/BerkAI
2. Sağ üstteki **Fork** butonuna tıklayın
3. Kendi hesabınıza fork'lanmış repository'yi klonlayın:
```bash
git clone https://github.com/KULLANICI_ADINIZ/BerkAI.git
cd BerkAI
```

4. Upstream repository'yi ekleyin:
```bash
git remote add upstream https://github.com/bberkaysari/BerkAI.git
```

### Adım 3: Backend'i Kurun (.NET)

```bash
# Backend klasörüne gidin
cd backend

# Bağımlılıkları yükleyin
dotnet restore

# Veritabanı bağlantı ayarlarını yapılandırın
# backend/src/FashionEcommerce.WebAPI/appsettings.Development.json dosyasını oluşturun

# Veritabanını güncelleyin
cd src/FashionEcommerce.WebAPI
dotnet ef database update

# API'yi çalıştırın
dotnet run
```

API şu adreste çalışacak: `https://localhost:5001`

### Adım 4: Frontend'i Kurun (Next.js)

```bash
# Ana dizine dönün ve frontend klasörüne gidin
cd ../../frontend

# Bağımlılıkları yükleyin
npm install

# Çevre değişkenlerini ayarlayın
# .env.local dosyası oluşturun

# Geliştirme sunucusunu başlatın
npm run dev
```

Uygulama şu adreste çalışacak: `http://localhost:3000`

### Adım 5: Çevre Değişkenlerini Yapılandırın

#### Backend (`backend/src/FashionEcommerce.WebAPI/appsettings.Development.json`)

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=BerkAI;Trusted_Connection=True;TrustServerCertificate=True"
  },
  "JwtSettings": {
    "SecretKey": "buraya-güvenli-bir-anahtar-yazın-minimum-32-karakter",
    "Issuer": "BerkAI",
    "Audience": "BerkAI-Users",
    "ExpirationMinutes": 60
  },
  "GoogleAuth": {
    "ClientId": "google-client-id-buraya"
  }
}
```

#### Frontend (`frontend/.env.local`)

```env
NEXT_PUBLIC_API_URL=http://localhost:5000
NEXT_PUBLIC_GOOGLE_CLIENT_ID=google-client-id-buraya
```

## 🔧 Geliştirme Ortamını Test Edin

### Backend Testi
```bash
cd backend
dotnet build
dotnet test  # testler varsa
```

### Frontend Testi
```bash
cd frontend
npm run build
npm run lint
```

### Her İki Sunucuyu da Çalıştırın
Terminal 1 (Backend):
```bash
cd backend/src/FashionEcommerce.WebAPI
dotnet watch run
```

Terminal 2 (Frontend):
```bash
cd frontend
npm run dev
```

Tarayıcınızda `http://localhost:3000` adresini açın ve uygulamanın çalıştığını doğrulayın.

## 📚 Önemli Dosyalar ve Dokümanlar

Yeni ekip üyesinin okuması gerekenler:

1. **[README.md](./README.md)** - Proje genel bakış ve hızlı başlangıç
2. **[CONTRIBUTING.md](./CONTRIBUTING.md)** - Katkıda bulunma kuralları ve standartlar (İngilizce)
3. **[HR_VITON_README.md](./HR_VITON_README.md)** - AI sanal giyinme sistemi dokümantasyonu

## 🤝 İlk Katkıyı Yapma

### 1. Yeni Bir Branch Oluşturun
```bash
git checkout -b feature/ozellik-adi
# veya
git checkout -b fix/hata-duzeltmesi
```

### 2. Değişikliklerinizi Yapın
- Kod yazın veya değiştirin
- Kodunuzu test edin
- Commit yapın:
```bash
git add .
git commit -m "feat: yeni özellik eklendi"
```

### 3. Push Yapın ve Pull Request Açın
```bash
git push origin feature/ozellik-adi
```

GitHub'da:
1. Repository sayfanıza gidin
2. "Compare & pull request" butonuna tıklayın
3. Değişikliklerinizi açıklayın
4. "Create pull request" butonuna tıklayın

## 🎓 Öğrenme Kaynakları

### Backend (.NET)
- [.NET Dokümantasyonu (Türkçe)](https://learn.microsoft.com/tr-tr/dotnet/)
- [C# Programlama Rehberi](https://learn.microsoft.com/tr-tr/dotnet/csharp/)
- [Entity Framework Core](https://learn.microsoft.com/en-us/ef/core/)

### Frontend (Next.js/React)
- [Next.js Dokümantasyonu](https://nextjs.org/docs)
- [React Öğren](https://react.dev/learn)
- [TypeScript Dokümantasyonu](https://www.typescriptlang.org/docs/)
- [Tailwind CSS](https://tailwindcss.com/docs)

### Genel
- [Git Kullanımı](https://git-scm.com/book/tr/v2)
- [GitHub Flow](https://guides.github.com/introduction/flow/)

## 🆘 Sorun Giderme

### Sık Karşılaşılan Sorunlar

#### "dotnet command not found"
- .NET SDK'nın doğru yüklendiğinden emin olun
- Terminal'i kapatıp tekrar açın
- PATH değişkenini kontrol edin

#### "npm command not found"
- Node.js'in yüklendiğinden emin olun
- Terminal'i kapatıp tekrar açın

#### Backend başlamıyor
- Veritabanı bağlantı ayarlarını kontrol edin
- `dotnet ef database update` komutunu çalıştırdığınızdan emin olun
- Port 5000/5001'in kullanımda olmadığından emin olun

#### Frontend başlamıyor
- `npm install` komutunu çalıştırdınız mı?
- `.env.local` dosyası oluşturuldu mu?
- Port 3000'in kullanımda olmadığından emin olun

#### Veritabanı migration hataları
```bash
# Migration'ları sıfırlayın
cd backend/src/FashionEcommerce.WebAPI
dotnet ef database drop  # Dikkat: tüm verileri siler!
dotnet ef database update
```

## 📞 Yardım ve İletişim

Takıldığınızda:

1. **Dokümantasyonu** kontrol edin (README, CONTRIBUTING)
2. **Mevcut issue'ları** aratın - sorunuz yanıtlanmış olabilir
3. **Yeni issue** açın - detaylı açıklama ile
4. **Ekip üyelerine** ulaşın

## ✅ Kontrol Listesi

Yeni ekip üyesi için hazırlık listesi:

- [ ] Gerekli yazılımlar yüklendi (.NET SDK, Node.js, Git)
- [ ] Proje klonlandı
- [ ] Backend bağımlılıkları yüklendi (`dotnet restore`)
- [ ] Frontend bağımlılıkları yüklendi (`npm install`)
- [ ] Veritabanı ayarları yapılandırıldı
- [ ] Çevre değişkenleri ayarlandı
- [ ] Backend başarıyla çalıştı
- [ ] Frontend başarıyla çalıştı
- [ ] CONTRIBUTING.md okundu
- [ ] İlk test değişikliği yapıldı

## 🎉 Hoş Geldiniz!

BerkAI ekibine hoş geldiniz! Katkılarınız için teşekkür ederiz. Herhangi bir sorunuz varsa çekinmeden sorun.

---

**Son Güncelleme**: 31 Aralık 2024
