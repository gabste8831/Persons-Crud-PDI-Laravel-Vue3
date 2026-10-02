<script setup>
import { onMounted, ref } from 'vue';
import { api } from '../api';
import { formatarDocumento, formatarTelefone } from '../formatters';

const props = defineProps({
    pessoa: { type: Object, required: true },
});

const emit = defineEmits(['editar', 'voltar']);

// Começa com o que veio da lista e atualiza com o registro do servidor,
// para não exibir dados velhos se alguém alterou a pessoa nesse meio-tempo.
const dados = ref(props.pessoa);
const erro = ref('');

onMounted(async () => {
    try {
        dados.value = await api.get(`/pessoas/${props.pessoa.id}`);
    } catch (e) {
        erro.value = e.message;
    }
});

const formatarData = (valor) => (valor ? new Date(valor).toLocaleString('pt-BR') : '—');
</script>

<template>
    <div class="rounded-xl border border-borda bg-cartao p-6 text-cartao-texto shadow-sm">
        <h2 class="text-lg font-semibold">{{ dados.nome }}</h2>
        <span
            class="mt-1 inline-block rounded-full px-2 py-0.5 text-xs"
            :class="dados.tipo === 'juridica'
                ? 'bg-juridica-fundo text-juridica'
                : 'bg-fisica-fundo text-fisica'"
        >
            {{ dados.tipo === 'juridica' ? 'Pessoa jurídica' : 'Pessoa física' }}
        </span>

        <p v-if="erro" class="mt-4 rounded-md bg-perigo-fundo px-4 py-3 text-sm text-perigo">{{ erro }}</p>

        <dl class="mt-6 grid gap-4 sm:grid-cols-2">
            <div>
                <dt class="text-xs uppercase tracking-wide text-suave">
                    {{ dados.tipo === 'juridica' ? 'CNPJ' : 'CPF' }}
                </dt>
                <dd class="mt-1">{{ formatarDocumento(dados.cpf) }}</dd>
            </div>
            <div>
                <dt class="text-xs uppercase tracking-wide text-suave">Telefone</dt>
                <dd class="mt-1">{{ formatarTelefone(dados.telefone) }}</dd>
            </div>
            <div class="sm:col-span-2">
                <dt class="text-xs uppercase tracking-wide text-suave">E-mail</dt>
                <dd class="mt-1 break-all">{{ dados.email }}</dd>
            </div>
            <div>
                <dt class="text-xs uppercase tracking-wide text-suave">Cadastrado em</dt>
                <dd class="mt-1 text-sm text-suave">{{ formatarData(dados.created_at) }}</dd>
            </div>
            <div>
                <dt class="text-xs uppercase tracking-wide text-suave">Última alteração</dt>
                <dd class="mt-1 text-sm text-suave">{{ formatarData(dados.updated_at) }}</dd>
            </div>
        </dl>

        <div class="mt-6 flex gap-3">
            <button
                class="rounded-md bg-destaque px-4 py-2 text-destaque-texto transition hover:bg-destaque-hover"
                @click="emit('editar', dados)"
            >
                Alterar
            </button>
            <button
                class="rounded-md border border-campo px-4 py-2 transition hover:bg-superficie-hover"
                @click="emit('voltar')"
            >
                Voltar
            </button>
        </div>
    </div>
</template>
