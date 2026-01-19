import axios from "./axios";

export async function getMessagesByCouple(coupleId, page = 1, limit = 10) {
  const res = await axios.get(
    `/admin/couples/${coupleId}/messages`,
    { params: { page, limit } }
  );
  return res.data; // { items, total, page, limit }
}




export async function deleteMessage(messageId) {
  const res = await axios.delete(`/admin/messages/${messageId}`);
  return res.data;
}
