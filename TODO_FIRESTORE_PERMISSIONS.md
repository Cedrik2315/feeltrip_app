# Firestore Permissions Fix - Approved Plan & Progress Tracker

**Status:** Approved by user. No code changes needed (rules/code correct).

## Steps:
- [ ] **1. Deploy rules**  
  Run: `firebase deploy --only firestore:rules`  
  *Deploys local firestore.rules to Firebase project feeltrip-app*

- [ ] **2. Verify Firebase Console**  
  - Go to https://console.firebase.google.com/project/feeltrip-app/firestore  
  - Rules tab: Shows deployed rules (not "default" locked mode)  
  - Data tab: Default DB created (if not, create us-central1 production)  

- [ ] **3. Test on device**  
  - Restart app/emulator  
  - Auth/login  
  - Check logs: No "PERMISSION_DENIED", see "Documento users/xxx verificado/creado"  

- [ ] **4. Mark complete**  

## Expected Result:  
Permission error gone. User doc created on first auth.

**Next:** Execute step 1?

