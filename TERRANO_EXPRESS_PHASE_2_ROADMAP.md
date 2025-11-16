# Terrano Express - Phase 2 Roadmap & Next Steps

**Date**: 2025-11-16
**Phase Actuelle**: 2.1 → 2.2 (Transition en cours)
**Statut Backend**: ✅ Opérationnel avec JWT authentifié

---

## 🎯 État Actuel du Projet

### ✅ Accomplissements Récents

1. **Backend API v2.0.0** - 100% Opérationnel
   - ✅ 61 endpoints API créés (9 modules)
   - ✅ Serveur Express fonctionnel sur port 3001
   - ✅ JWT authentification RÉSOLUE
   - ✅ Connexion Supabase opérationnelle
   - ✅ 3/6 endpoints testés et fonctionnels

2. **Infrastructure Supabase**
   - ✅ 12/13 conteneurs Docker sains
   - ✅ PostgreSQL avec 6 tables créées
   - ✅ Kong Gateway configuré
   - ✅ Données de test existantes

3. **Documentation Créée**
   - ✅ [TERRANO_EXPRESS_JWT_RESOLUTION_SUCCESS.md](file:///C:/Users/HP/TERRANO_EXPRESS_JWT_RESOLUTION_SUCCESS.md)
   - ✅ [TERRANO_EXPRESS_PHASE_2_STATUS_REPORT.md](file:///C:/Users/HP/TERRANO_EXPRESS_PHASE_2_STATUS_REPORT.md)
   - ✅ [TERRANO_EXPRESS_PHASE_2_API_ROUTES_COMPLETE.md](file:///C:/Users/HP/TERRANO_EXPRESS_PHASE_2_API_ROUTES_COMPLETE.md)

---

## 📋 Tâches Immédiates (Priorité Haute)

### 1. Alignement Schéma Routes/Schedules ⚠️ EN COURS

**Problème Identifié:**
Les API routes et schedules utilisent des noms de colonnes différents du schéma de la base de données.

**Schéma DB (Actuel - Correct):**
```sql
routes (
  id uuid,
  company_id uuid → companies(id),
  departure_city_id uuid → cities(id),
  arrival_city_id uuid → cities(id),
  duration_minutes integer,
  distance_km numeric(10,2),
  is_active boolean
)
```

**API Routes (À Corriger):**
- Attend: `origin` (text), `destination` (text)
- Doit utiliser: `departure_city_id` (uuid), `arrival_city_id` (uuid)

**Actions Requises:**
1. Lire `/opt/terrano-express-backend/src/routes/routesRoutes.ts`
2. Mettre à jour les queries Supabase pour utiliser `departure_city_id`/`arrival_city_id`
3. Ajouter des JOIN avec la table `cities` pour retourner les noms des villes
4. Faire de même pour `schedulesRoutes.ts`
5. Tester les endpoints après modification

**Commandes de Test:**
```bash
# Après corrections
curl http://localhost:3001/api/routes
curl http://localhost:3001/api/schedules
```

---

### 2. Tests Exhaustifs des Endpoints

**Endpoints à Tester (61 total):**

#### ✅ Testés et Fonctionnels (3)
1. GET /api/companies ✅
2. GET /api/cities ✅
3. GET /api/buses ✅

#### ⏳ À Tester (58)

**Routes API (12 endpoints):**
- GET /api/routes
- GET /api/routes/search
- GET /api/routes/popular
- GET /api/routes/:id
- GET /api/routes/:id/schedules
- GET /api/routes/:id/stats
- POST /api/routes
- PUT /api/routes/:id
- PATCH /api/routes/:id/status
- PATCH /api/routes/:id/price
- DELETE /api/routes/:id

**Schedules API (10 endpoints):**
- GET /api/schedules
- GET /api/schedules/search
- GET /api/schedules/today
- GET /api/schedules/upcoming
- GET /api/schedules/:id
- GET /api/schedules/:id/bookings
- POST /api/schedules
- PUT /api/schedules/:id
- PATCH /api/schedules/:id/status
- DELETE /api/schedules/:id

**Bookings API (11 endpoints):**
- GET /api/bookings
- GET /api/bookings/user/:userId
- GET /api/bookings/:id
- POST /api/bookings
- PUT /api/bookings/:id
- PATCH /api/bookings/:id/status
- PATCH /api/bookings/:id/payment
- POST /api/bookings/:id/cancel
- DELETE /api/bookings/:id

**Companies API (9 endpoints):**
- GET /api/companies/active
- GET /api/companies/:id
- GET /api/companies/:id/buses
- GET /api/companies/:id/routes
- GET /api/companies/:id/stats
- POST /api/companies
- PUT /api/companies/:id
- PATCH /api/companies/:id/status
- DELETE /api/companies/:id

**Cities API (7 endpoints):**
- GET /api/cities/popular
- GET /api/cities/:id
- GET /api/cities/:id/routes
- POST /api/cities
- PUT /api/cities/:id
- DELETE /api/cities/:id

**Buses API (12 endpoints):**
- GET /api/buses/available
- GET /api/buses/:id
- GET /api/buses/:id/schedules
- GET /api/buses/:id/stats
- POST /api/buses
- PUT /api/buses/:id
- PATCH /api/buses/:id/status
- DELETE /api/buses/:id

---

### 3. Création de Données de Test Complètes

**Données Existantes:**
- ✅ 3 companies (City Express, etc.)
- ✅ Plusieurs cities (Bukavu, etc.)
- ✅ 1 bus (KIN-0001, Toyota Coaster)

**Données à Créer:**
```sql
-- Routes (5 routes minimum)
INSERT INTO routes (company_id, departure_city_id, arrival_city_id, duration_minutes, distance_km)
VALUES
  -- Kinshasa → Bukavu (exemple)
  ('company_uuid', 'kinshasa_uuid', 'bukavu_uuid', 180, 250),
  -- Ajouter 4 autres routes...
  ;

-- Schedules (10 schedules minimum)
INSERT INTO schedules (route_id, bus_id, departure_time, arrival_time, available_seats, price, status)
VALUES
  -- Schedule pour aujourd'hui
  ('route_uuid', 'bus_uuid', NOW() + INTERVAL '2 hours', NOW() + INTERVAL '5 hours', 25, 15000, 'scheduled'),
  -- Ajouter 9 autres schedules...
  ;

-- Bookings (5 bookings de test)
INSERT INTO bookings (user_id, schedule_id, passenger_name, passenger_phone, num_seats, total_price, status)
VALUES
  ('user_uuid', 'schedule_uuid', 'Jean Doe', '+243999000001', 2, 30000, 'confirmed'),
  -- Ajouter 4 autres bookings...
  ;
```

**Script de Création:**
```bash
# Créer script SQL complet
ssh root@72.62.35.45 "cat > /tmp/test_data.sql << 'SQL_EOF'
-- Contenu SQL ici
SQL_EOF"

# Exécuter le script
docker exec supabase-db psql -U postgres -d postgres -f /tmp/test_data.sql
```

---

## 🚀 Phase 2.2 - Intégration Paiements & Notifications

### Objectifs Phase 2.2

1. **Système de Paiement Mobile Money**
   - Orange Money (Côte d'Ivoire)
   - MTN Money (Afrique)
   - Moov Money (Côte d'Ivoire)

2. **Système de Paiement par Carte**
   - Stripe (international)
   - PayPal (alternatif)

3. **Notifications Email**
   - Confirmation de réservation
   - Annulation de voyage
   - Rappels avant départ
   - Factures/reçus

4. **Notifications SMS**
   - Confirmation instantanée
   - Rappels 24h avant
   - Changements d'horaire

---

### Architecture Paiements Proposée

```typescript
// 1. Payment Routes (/api/payments)
POST /api/payments/mobile-money/initiate
POST /api/payments/mobile-money/verify
POST /api/payments/card/initiate
POST /api/payments/card/verify
POST /api/payments/refund
GET /api/payments/transactions
GET /api/payments/transactions/:id

// 2. Database Schema
payments (
  id uuid,
  booking_id uuid → bookings(id),
  amount numeric(10,2),
  currency varchar(3) DEFAULT 'XOF',
  payment_method varchar(50), // 'orange_money', 'mtn_money', 'stripe', 'paypal'
  transaction_id varchar(255),
  status varchar(50), // 'pending', 'processing', 'completed', 'failed', 'refunded'
  provider_response jsonb,
  created_at timestamp,
  completed_at timestamp
)
```

---

### Architecture Notifications Proposée

```typescript
// 1. Notification Routes (/api/notifications)
POST /api/notifications/send-email
POST /api/notifications/send-sms
GET /api/notifications/templates
GET /api/notifications/history/:userId

// 2. Email Templates (Resend.com ou SendGrid)
- booking_confirmation.html
- booking_cancellation.html
- departure_reminder.html
- receipt.html

// 3. SMS Provider (Twilio, Africa's Talking)
- Configuration credentials
- Template SMS court
- Queue system pour envoi différé
```

---

## 📅 Timeline Recommandée

### Semaine 1 (Aujourd'hui → J+7)
- **Jour 1-2**: Alignement schéma + tests endpoints
- **Jour 3-4**: Création données test + documentation
- **Jour 5-7**: Début intégration Mobile Money

### Semaine 2 (J+8 → J+14)
- **Jour 8-10**: Finir Mobile Money + tests
- **Jour 11-12**: Intégration Stripe/PayPal
- **Jour 13-14**: Système notifications Email

### Semaine 3 (J+15 → J+21)
- **Jour 15-16**: Système notifications SMS
- **Jour 17-18**: Tests end-to-end complets
- **Jour 19-21**: Documentation Swagger + déploiement

---

## 🛠️ Outils & Technologies à Utiliser

### Paiements
- **Orange Money API**: https://developer.orange.com/apis/orange-money-webpay
- **MTN MoMo API**: https://momodeveloper.mtn.com/
- **Stripe**: https://stripe.com/docs/api
- **PayPal**: https://developer.paypal.com/

### Notifications
- **Resend** (Email): https://resend.com/ (déjà configuré)
- **SendGrid** (Email alternatif): https://sendgrid.com/
- **Twilio** (SMS): https://www.twilio.com/
- **Africa's Talking** (SMS Afrique): https://africastalking.com/

### Documentation
- **Swagger/OpenAPI**: https://swagger.io/
- **Postman**: Pour tests manuels
- **Jest**: Tests unitaires

---

## 📊 Métriques de Succès Phase 2

### Phase 2.1 (Actuel)
- [x] 61 endpoints créés ✅
- [x] Backend opérationnel ✅
- [x] JWT authentification fonctionnelle ✅
- [ ] Tous endpoints testés (3/61 = 5%)
- [ ] Schéma aligné
- [ ] Données de test complètes

### Phase 2.2 (Objectif)
- [ ] 3 méthodes Mobile Money intégrées
- [ ] Paiement carte fonctionnel
- [ ] 4 templates email créés
- [ ] SMS notifications actives
- [ ] Taux de succès paiement > 95%
- [ ] Temps réponse API < 500ms

### Phase 2.3-2.4 (Futur)
- [ ] Tests unitaires (couverture > 80%)
- [ ] Documentation Swagger complète
- [ ] Rate limiting implémenté
- [ ] Caching Redis opérationnel

---

## 🔗 Ressources Utiles

### Documentation Projet
1. [TERRANO_EXPRESS_JWT_RESOLUTION_SUCCESS.md](file:///C:/Users/HP/TERRANO_EXPRESS_JWT_RESOLUTION_SUCCESS.md) - Résolution JWT
2. [TERRANO_EXPRESS_PHASE_2_API_ROUTES_COMPLETE.md](file:///C:/Users/HP/TERRANO_EXPRESS_PHASE_2_API_ROUTES_COMPLETE.md) - API Routes
3. [TERRANO_EXPRESS_PHASE_2_STATUS_REPORT.md](file:///C:/Users/HP/TERRANO_EXPRESS_PHASE_2_STATUS_REPORT.md) - État Phase 2

### Accès VPS
```bash
# SSH
ssh root@72.62.35.45

# Backend logs
tail -f /var/log/terrano-backend-jwt-fixed.log

# Test endpoints
curl http://localhost:3001/health
curl http://localhost:3001/api
```

### Configuration Supabase
```bash
# Env Supabase
cat /opt/supabase/docker/.env | grep JWT_SECRET

# Env Backend
cat /opt/terrano-express-backend/.env | grep SUPABASE
```

---

## ⚡ Actions Rapides

### Redémarrer Backend
```bash
ssh root@72.62.35.45 "fuser -k 3001/tcp && cd /opt/terrano-express-backend && source /root/.nvm/nvm.sh && nvm use 24.11.1 && nohup npm run dev > /var/log/terrano-backend.log 2>&1 &"
```

### Vérifier Status
```bash
ssh root@72.62.35.45 "netstat -tlnp | grep 3001 && curl -s http://localhost:3001/health"
```

### Tester Endpoint
```bash
ssh root@72.62.35.45 "curl -s http://localhost:3001/api/companies | head -c 300"
```

---

## 🎯 Prochaines Étapes Concrètes

### Aujourd'hui
1. ⏳ Corriger `routesRoutes.ts` et `schedulesRoutes.ts`
2. ⏳ Tester les endpoints modifiés
3. ⏳ Créer script de données de test

### Cette Semaine
4. ⏳ Rechercher APIs Mobile Money (Orange, MTN, Moov)
5. ⏳ Créer compte développeur Stripe
6. ⏳ Configurer templates Email avec Resend

### Semaine Prochaine
7. ⏳ Implémenter premier flux paiement Mobile Money
8. ⏳ Créer système de webhooks paiements
9. ⏳ Tests end-to-end flux complet réservation

---

## 📞 Support & Questions

Si vous rencontrez des problèmes:

1. **Problème JWT**: Consultez [TERRANO_EXPRESS_JWT_RESOLUTION_SUCCESS.md](file:///C:/Users/HP/TERRANO_EXPRESS_JWT_RESOLUTION_SUCCESS.md)
2. **Problème Backend**: Vérifier `/var/log/terrano-backend-jwt-fixed.log`
3. **Problème Database**: `docker logs supabase-db --tail 50`
4. **Problème Kong**: `docker logs supabase-kong --tail 50`

---

**Créé**: 2025-11-16
**Phase**: 2.1 → 2.2 (Transition)
**Statut**: ✅ Backend Opérationnel, Prêt pour Phase 2.2
**Prochain Objectif**: Alignement schéma + Intégration Paiements

---

🚀 **Le backend est maintenant prêt pour l'intégration des paiements et notifications !**
