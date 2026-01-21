import axios from "./axios";

export async function getMemoriesByCouple(coupleId, page = 1, limit = 10) {
  const res = await axios.get(
    `/admin/couples/${coupleId}/memories`,
    { params: { page, limit } }
  );
  return res.data; // { items, total, page, limit }
}
