import { toast } from 'https://unpkg.com/vue3-toastify@0.2.1/dist/index.mjs';
import { createApp, onMounted, reactive, ref, toRaw } from 'vue';

const app = createApp({
  setup() {
    const characters = ref([]);
    const currentCharacter = reactive({});
    const show = reactive({
      body: false,
      loading: false,
      register: false,
      delete: false,
    });
    const registerData = reactive({
      date: new Date(Date.now() - new Date().getTimezoneOffset() * 60000).toISOString().substr(0, 10),
      firstName: '',
      lastName: '',
      nationality: '',
      height: 175,
      gender: '',
    });
    const allowDelete = ref(false);
    const showNationality = ref(false);
    const characterSlots = ref(0);
    const loadingText = ref('');
    const selectedCharacterId = ref(-1);
    const translations = reactive({});

    const re = '(' + blockedWords.join('|') + ')\\b';
    const regTest = new RegExp(re, 'i');

    const api = {
      async get(url) {
        return fetch(url, {
          method: 'GET',
          headers: {
            'Content-Type': 'application/json',
          },
        }).then(response => {
          if (!response.ok) {
            throw new Error(response.statusText);
          }
          return response.json();
        });
      },
      async post(url, body) {
        const response = await fetch(url, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify(body),
        });
        if (!response.ok) {
          throw new Error(response.statusText);
        }
        return await response.json();
      },
    };

    const formatMoney = (value) => {
      return new Intl.NumberFormat(toRaw(translations)?.['money_locale'] ?? 'en-US', { style: 'currency', currency: toRaw(translations)?.['money_currency'] ?? 'USD', maximumFractionDigits: 0 }).format(value)
    };

    const clickCharacter = (idx) => {
      selectedCharacterId.value = idx;

      if (characters.value[idx]) {
        api.post('https://if-zombie_multicharacter/characterPed', {
          character: characters.value[idx],
        });
        show.register = false;
        show.delete = false;
      } else {
        api.post('https://if-zombie_multicharacter/characterPed', {});
        resetRegisterData();
        show.delete = false;
        show.register = true;
      }
    };

    const deleteCharacter = () => {
      if (show.delete) {
        show.delete = false;
        show.body = false;
        api.post('https://if-zombie_multicharacter/removeCharacter', {
          identifier: characters.value[selectedCharacterId.value].identifier,
        });
      } else if (show.body && !show.register) {
        show.delete = true;
      }
    };

    const playCharacter = () => {
      if (selectedCharacterId.value !== -1) {
        let data = characters.value[selectedCharacterId.value];

        if (data) {
          data.id = selectedCharacterId.value;
          api.post('https://if-zombie_multicharacter/selectCharacter', {
            character: data,
          });
          setTimeout(() => {
            show.body = false;
          }, 500);
        } else {
          resetRegisterData();
          show.register = true;
        }
      }
    };

    const toggleGender = (newGender) => {
      registerData.gender = newGender;
      api.post('https://if-zombie_multicharacter/characterPed', {
        gender: newGender
      })
    };

    const createCharacter = () => {
      const blockedWordsTest = !regTest.test(registerData.firstName) && !regTest.test(registerData.nationality) && !regTest.test(registerData.lastName);

      if (blockedWordsTest && validateRegisterData()) {
        show.body = false;
        show.register = false;
        api.post('https://if-zombie_multicharacter/createNewCharacter', {
          identity: {
            firstName: registerData.firstName,
            lastName: registerData.lastName,
            nationality: registerData.nationality,
            height: registerData.height,
            birthDate: registerData.date,
            gender: registerData.gender,
          },
          id: selectedCharacterId.value
        });
      } else {
        showValidationError(blockedWordsTest);
      }
    };

    const translate = (phrase) => toRaw(translations)[phrase] || phrase;

    const validateRegisterData = () => {
      return registerData.firstName && registerData.lastName && registerData.gender && (showNationality.value ? registerData.nationality : true) && registerData.height && registerData.date;
    };

    const resetRegisterData = () => {
      registerData.firstName = '';
      registerData.lastName = '';
      registerData.nationality = '';
      registerData.height = 175;
      registerData.gender = '';
      registerData.date = new Date(Date.now() - new Date().getTimezoneOffset() * 60000).toISOString().substr(0, 10);
    };

    const showValidationError = (blockedWordsTest) => {
      const message = !blockedWordsTest ? translate('bad_words') : translate('forgotten_field');
      console.log('showValidationError -> ' + message);
      toast(translate('ran_into_issue') + ' ' + message, {
        "theme": "dark",
        "type": "error",
        "autoClose": 5000,
      })
    };

    onMounted(() => {
      let loadingProgress = 0;
      let loadingDots = 0;

      api.post('https://if-zombie_multicharacter/uiReady', {});
      window.addEventListener('message', (event) => {
        const data = event.data;

        switch (data.action) {
          case 'ui':
            Object.assign(translations, data.translations);
            characterSlots.value = data.characterSlots;
            selectedCharacterId.value = -1;
            show.register = false;
            show.delete = false;
            show.body = data.toggle;
            allowDelete.value = data.enableDeleteButton;
            showNationality.value = data.showNationality;

            if (data.toggle) {
              show.loading = true;
              loadingText.value = translate('retrieving_player_data');

              const DotsInterval = setInterval(() => {
                loadingDots++;
                loadingProgress++;

                updateLoadingText(loadingProgress);

                if (loadingDots === 4) {
                  loadingDots = 0;
                }
              }, 500);

              setTimeout(() => {
                api.post('https://if-zombie_multicharacter/setupCharacters');

                setTimeout(() => {
                  clearInterval(DotsInterval);
                  resetLoadingState();
                }, 2000);
              }, 2000);
            }
            break;

          case 'setupCharacters':
            characters.value = data.characters;
            break;

          case 'setupCharInfo':
            Object.assign(currentCharacter, data.currentCharacter);
            break;
        }
      });
    });

    const updateLoadingText = (progress) => {
      if (progress === 3) {
        loadingText.value = translate('validating_player_data');
      } else if (progress === 4) {
        loadingText.value = translate('retrieving_characters');
      } else if (progress === 6) {
        loadingText.value = translate('validating_characters');
      }
    };

    const resetLoadingState = () => {
      loadingText.value = translate('retrieving_player_data');
      show.loading = false;
      api.post('https://if-zombie_multicharacter/removeBlur');
    };

    return {
      characters,
      currentCharacter,
      show,
      registerData,
      allowDelete,
      showNationality,
      characterSlots,
      loadingText,
      selectedCharacterId,
      translations,
      clickCharacter,
      deleteCharacter,
      toggleGender,
      playCharacter,
      createCharacter,
      translate,
      formatMoney
    };
  },
});

app.mount('#app');
